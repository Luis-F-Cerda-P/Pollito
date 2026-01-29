class OtpSessionsController < ApplicationController
  allow_unauthenticated_access except: %i[ destroy ]
  before_action :set_user_from_session, only: %i[password authenticate]
  before_action :set_verification, only: %i[verify confirm]

  rate_limit to: 5, within: 15.minutes, only: :create, with: -> { redirect_to login_path, alert: "Too many login attempts. Please try again later." }
  rate_limit to: 10, within: 3.minutes, only: :confirm, with: -> { redirect_to login_path, alert: "Too many verification attempts. Please try again later." }

  def new
  end

  def create
    email = params[:email_address]&.strip&.downcase
    user = User.find_by(email_address: email)

    if user&.admin?
      session[:admin_email] = email
      redirect_to login_password_path
    elsif user
      send_login_otp(user)
    else
      redirect_to signup_path(email: email), notice: "Please sign up to continue."
    end
  end

  def password
    redirect_to login_path unless @user&.admin?
  end

  def authenticate
    if @user&.admin? && @user.authenticate(params[:password])
      start_new_session_for(@user)
      session.delete(:admin_email)
      redirect_to after_authentication_url, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid password."
      render :password, status: :unprocessable_entity
    end
  end

  def verify
    if @verification.nil? || !@verification.usable?
      redirect_to login_path, alert: "Verification expired or invalid. Please try again."
    end
  end

  def confirm
    if @verification.nil? || !@verification.usable?
      redirect_to login_path, alert: "Verification expired or invalid. Please try again."
      return
    end

    result = @verification.verify(params[:otp])

    case result
    when :valid
      user = User.find_by(email_address: @verification.email_address)
      if user
        @verification.destroy
        start_new_session_for(user)
        redirect_to after_authentication_url, notice: "Signed in successfully."
      else
        redirect_to login_path, alert: "User not found."
      end
    when :expired
      redirect_to login_path, alert: "Code expired. Please request a new one."
    when :max_attempts
      redirect_to login_path, alert: "Too many failed attempts. Please request a new code."
    else
      flash.now[:alert] = "Invalid code. Please try again."
      render :verify, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session if Current.session
    redirect_to root_path, notice: "Signed out successfully."
  end

  private

  def set_user_from_session
    @user = User.find_by(email_address: session[:admin_email]) if session[:admin_email]
  end

  def set_verification
    @verification = EmailVerification.find_by(id: params[:token])
  end

  def send_login_otp(user)
    verification, otp = EmailVerification.create_for(
      email_address: user.email_address,
      purpose: :login
    )

    OtpMailer.login_code(user, otp).deliver_later

    redirect_to login_verify_path(token: verification.id), notice: "Check your email for a login code."
  end
end

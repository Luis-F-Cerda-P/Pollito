class RegistrationsController < ApplicationController
  layout "auth"

  allow_unauthenticated_access
  before_action :set_verification, only: %i[verify confirm]

  rate_limit to: 5, within: 15.minutes, only: :create, with: -> { redirect_to signup_path, alert: "Too many signup attempts. Please try again later." }
  rate_limit to: 10, within: 3.minutes, only: :confirm, with: -> { redirect_to signup_path, alert: "Too many verification attempts. Please try again later." }

  def new
    @email = params[:email]
  end

  def create
    email = params[:email_address]&.strip&.downcase
    name = params[:name]&.strip

    if email.blank? || name.blank?
      flash.now[:alert] = "Email and name are required."
      render :new, status: :unprocessable_entity
      return
    end

    if User.exists?(email_address: email)
      redirect_to login_path(email_address: email), notice: "You already have an account. Please sign in."
      return
    end

    verification, otp = EmailVerification.create_for(
      email_address: email,
      name: name,
      purpose: :registration
    )

    OtpMailer.registration_code(email, name, otp).deliver_later

    redirect_to signup_verify_path(token: verification.id), notice: "Check your email for a verification code."
  end

  def verify
    if @verification.nil? || !@verification.usable?
      redirect_to signup_path, alert: "Verification expired or invalid. Please try again."
    end
  end

  def confirm
    if @verification.nil? || !@verification.usable?
      redirect_to signup_path, alert: "Verification expired or invalid. Please try again."
      return
    end

    result = @verification.verify(params[:otp])

    case result
    when :valid
      user = User.find_or_create_from_verification!(@verification)
      @verification.destroy
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Welcome to Pollito!"
    when :expired
      redirect_to signup_path, alert: "Code expired. Please request a new one."
    when :max_attempts
      redirect_to signup_path, alert: "Too many failed attempts. Please request a new code."
    else
      flash.now[:alert] = "Invalid code. Please try again."
      render :verify, status: :unprocessable_entity
    end
  end

  private

  def set_verification
    @verification = EmailVerification.find_by(id: params[:token])
  end
end

class OtpMailer < ApplicationMailer
  def login_code(user, otp)
    @user = user
    @otp = otp

    mail(
      to: user.email_address,
      subject: "Your login code for Pollito"
    )
  end

  def registration_code(email, name, otp)
    @email = email
    @name = name
    @otp = otp

    mail(
      to: email,
      subject: "Verify your email for Pollito"
    )
  end
end

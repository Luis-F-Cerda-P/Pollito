class OtpMailerPreview < ActionMailer::Preview
  def registration_code
    OtpMailer.registration_code("test@example.com", "Test User", "123456")
  end
end

class EmailVerification < ApplicationRecord
  MAX_ATTEMPTS = 5
  EXPIRY_DURATION = 15.minutes

  enum :purpose, { login: 0, registration: 1 }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true
  validates :otp_digest, presence: true
  validates :purpose, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current).where("attempts < ?", MAX_ATTEMPTS) }

  class << self
    def create_for(email_address:, purpose:, name: nil)
      otp = generate_otp
      verification = create!(
        email_address: email_address,
        name: name,
        otp_digest: BCrypt::Password.create(otp),
        purpose: purpose,
        expires_at: EXPIRY_DURATION.from_now
      )
      [ verification, otp ]
    end

    def generate_otp
      SecureRandom.random_number(10**6).to_s.rjust(6, "0")
    end
  end

  def verify(otp)
    return :expired if expired?
    return :max_attempts if max_attempts_reached?

    if BCrypt::Password.new(otp_digest) == otp
      :valid
    else
      increment!(:attempts)
      max_attempts_reached? ? :max_attempts : :invalid
    end
  end

  def expired?
    expires_at <= Time.current
  end

  def max_attempts_reached?
    attempts >= MAX_ATTEMPTS
  end

  def usable?
    !expired? && !max_attempts_reached?
  end
end

require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module SignInHelper
  def sign_in_as(user)
    verification, otp = EmailVerification.create_for(
      email_address: user.email_address,
      purpose: :login
    )

    post login_verify_url(token: verification.id, otp: otp)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end

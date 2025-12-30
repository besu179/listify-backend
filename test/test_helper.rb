ENV["RAILS_ENV"] ||= "test"
ENV["DEVISE_JWT_SECRET_KEY"] = "a" * 100 # Dummy secret for test environment
# Disable bootsnap compilation in test environment to avoid Windows-specific "Interrupt" issues
ENV["DISABLE_BOOTSNAP"] = "1" if ENV["RAILS_ENV"] == "test"

require_relative "../config/environment"
require "rails/test_help"
require "devise/jwt/test_helpers"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include Devise::JWT::TestHelpers

    def authenticated_header(user)
      headers = { "Accept" => "application/json", "Content-Type" => "application/json" }
      Devise::JWT::TestHelpers.auth_headers(headers, user)
    end
  end
end

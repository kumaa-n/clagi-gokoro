require "omniauth"

RSpec.configure do |config|
  config.before(:suite) do
    OmniAuth.config.test_mode = true
    OmniAuth.config.logger = Logger.new(nil)
  end

  config.after(:each) do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end

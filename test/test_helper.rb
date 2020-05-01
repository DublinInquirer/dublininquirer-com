ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'
require 'mocha/minitest'

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com'
})

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

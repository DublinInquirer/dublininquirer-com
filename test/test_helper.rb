ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'vcr'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.allow_http_connections_when_no_cassette = true
  config.hook_into :webmock
end

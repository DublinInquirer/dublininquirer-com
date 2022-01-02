require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.force_ssl = true
  config.cache_classes = true
  config.cache_store = :redis_cache_store
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.require_master_key = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # config.action_controller.asset_host = Rails.application.credentials.dig(:production, :aws, :asset_cloudfront_url)
  # config.active_storage.service = :amazon
  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass
  config.assets.js_compressor = :terser

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false
  config.active_storage.service = :local
  config.log_level = :info
  config.log_tags = [ :request_id ]
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
  config.active_record.dump_schema_after_migration = false
  config.exceptions_app = self.routes

  # mailer
  
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: (ENV['PRODUCTION_ENVIRONMENT'] == 'staging') ? 'https://staging.dublininquirer.com' : 'https://www.dublininquirer.com' }
  config.action_mailer.delivery_method = :postmark
  config.action_mailer.postmark_settings = {
    api_token: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :postmark, :api_key)
  }
end

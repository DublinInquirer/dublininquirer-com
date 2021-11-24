Gibbon::Request.api_key = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :mailchimp, :api_key)
Gibbon::Request.symbolize_keys = true
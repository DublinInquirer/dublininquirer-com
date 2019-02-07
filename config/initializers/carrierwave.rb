if Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :aws, :access_key_id),
      aws_secret_access_key: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :aws, :secret_access_key),
      region: 'eu-west-1'
    }

    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.asset_host = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :aws, :ugc_cloudfront_url)
    config.fog_directory  = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :aws, :bucket)
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
    config.storage = :fog
  end
end

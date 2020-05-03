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
      aws_access_key_id: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :linode, :access_key_id),
      aws_secret_access_key: Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :linode, :secret_access_key),
      endpoint: 'eu-central-1.linodeobjects.com',
      region: ''
    }

    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.asset_host = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :aws, :ugc_cloudfront_url)
    config.fog_directory  = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :linode, :bucket)
    config.s3_access_policy = :public_read
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
    config.storage = :fog
  end
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
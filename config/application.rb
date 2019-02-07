require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Inquirer
  class Application < Rails::Application
    config.load_defaults 5.2
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.assets false
      g.factory_bot true
    end
  end
end

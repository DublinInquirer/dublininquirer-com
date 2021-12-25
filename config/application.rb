require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Inquirer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.active_job.queue_adapter = :sucker_punch
    config.sass.preferred_syntax = :sass

    config.generators do |g|
      g.assets false
      g.factory_bot true
    end
    
    config.time_zone = "Europe/Dublin"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end

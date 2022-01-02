source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '~> 7.0.x'
gem 'pg'
gem "puma"
gem 'haml'
gem 'mini_racer', platforms: :ruby
gem 'dotenv-rails'
gem 'bcrypt', '~> 3.1.7'
gem 'http'

gem 'redis', '~> 4.0'
gem 'sucker_punch', '~> 2.0'

gem 'oj'
gem 'roo' # CSV importing
gem 'sanitize'
gem "nokogiri", ">= 1.10.4"
gem 'jbuilder', '~> 2.7'
gem 'kramdown'

# asset pipeline
gem 'terser'
gem 'sass-rails'
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# js bundling
gem "jsbundling-rails"
gem "stimulus-rails"
gem 'turbo-rails'

# css bundling
gem "cssbundling-rails"

gem 'meta-tags'
gem 'sitemap_generator'
gem 'gibbon' # mailchimp integration

gem 'textacular', git: 'https://github.com/textacular/textacular'
gem 'sorcery'
gem 'pretender'
gem 'namae'
gem 'countries'
gem 'country_select', '~> 3.1'
gem 'reverse_markdown' # used to re-display html after saving

gem 'browser'
gem 'kaminari' # pagination
gem 'plyr-rails'
gem 'rinku'
gem 'postmark-rails'
gem 'stripe'
gem 'stripe_event'
gem 'appsignal'

gem 'carrierwave', '~> 1.0'
gem "mini_magick", ">= 4.9.4"
gem 'fog-aws', group: :production
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  gem 'rack-mini-profiler'
  gem 'stripe-ruby-mock', '~> 2.5.8', :require => 'stripe_mock'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'mocha'
end

group :development do
  gem "memory_profiler"
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'rubocop', require: false
  gem 'squasher', require: false
end

group :test do
  gem 'capybara'
  gem 'webmock'
  gem 'webdrivers', '~> 3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

gem 'rails', '~> 6.0.x'
gem 'pg', '< 1.0.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'haml'
gem 'http'
gem 'oj'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.5'
gem 'kramdown'
gem 'meta-tags'
gem 'sitemap_generator'
gem 'mini_racer', platforms: :ruby
gem 'redis', '~> 4.0'
gem "nokogiri", ">= 1.10.4"
gem 'carrierwave', '~> 1.0'
gem "mini_magick", ">= 4.9.4"
gem 'sentry-raven'
gem 'sanitize'
gem 'sorcery'
gem 'textacular', "~> 5.0"
gem 'postmark-rails'
gem 'stripe'
gem 'sidekiq'
gem 'namae'
gem 'autoprefixer-rails'
gem 'rack-mini-profiler'
gem 'puma_worker_killer'
gem 'countries'
gem 'country_select', '~> 3.1'
gem 'reverse_markdown'
gem 'bcrypt', '~> 3.1.7'
gem 'browser'
gem 'kaminari' # pagination
gem 'pretender'
gem 'scout_apm'
gem 'plyr-rails'
gem 'rinku'
gem 'roo' # CSV importing
gem 'aws-sdk-s3', require: false
gem 'fog-aws', group: :production
gem 'turbolinks'
gem 'stripe_event'
gem 'stripe-ruby-mock', '~> 2.5.8', :require => 'stripe_mock'
gem 'webpacker', git: 'https://github.com/rails/webpacker.git'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'mocha'
end

group :development do
  gem "memory_profiler"
  gem "derailed_benchmarks"
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
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

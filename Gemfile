source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.0'
gem 'pg', '< 1.0.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'haml'
gem 'http'
gem 'oj'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'kramdown'
gem 'meta-tags'
gem 'sitemap_generator'
gem 'mini_racer', platforms: :ruby
gem 'redis', '~> 4.0'
gem 'aws-sdk-s3', require: false
gem 'webpacker', '~> 3.5'
gem 'nokogiri'
gem 'carrierwave', '~> 1.0'
gem 'mini_magick', '~> 4.8'
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
gem 'upmark'
gem 'bcrypt', '~> 3.1.7'
gem 'browser'
gem 'kaminari'
gem 'skylight'
gem 'pretender'
gem 'reverse_markdown'
gem 'scout_apm'
gem 'plyr-rails'
gem 'rinku'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'fog-aws', group: :production

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'webmock'
end

group :development do
  gem "memory_profiler"
  gem "derailed_benchmarks"
  gem 'rubocop'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener_web'
  gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

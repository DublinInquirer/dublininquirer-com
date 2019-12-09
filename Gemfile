source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.x'
gem 'pg', '< 1.0.0'
gem 'puma', '~> 3.12'
gem 'sass-rails', '~> 5.0'
gem 'haml'
gem 'http'
gem 'uglifier', '>= 1.3.0'
gem 'mini_racer', platforms: :ruby
gem 'webpacker', git: 'https://github.com/rails/webpacker.git'

gem 'redis', '~> 4.0'
gem 'sidekiq'

gem 'oj'
gem 'roo' # CSV importing
gem 'sanitize'
gem "nokogiri", ">= 1.10.4"
gem 'jbuilder', '~> 2.5'
gem 'kramdown'
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bcrypt', '~> 3.1.7'
gem 'webpacker-svelte', "~> 0.0.0"

gem 'meta-tags'
gem 'sitemap_generator'

gem 'textacular', "~> 5.0"
gem 'sorcery'
gem 'pretender'
gem 'namae'
gem 'countries'
gem 'country_select', '~> 3.1'
gem 'reverse_markdown' # for importing, can be pulled out soon

gem 'browser'
gem 'kaminari' # pagination
gem 'plyr-rails'
gem 'rinku'

gem 'sentry-raven'
gem 'postmark-rails'
gem 'stripe'
gem 'stripe_event'
gem 'scout_apm'

gem 'carrierwave', '~> 1.0'
gem "mini_magick", ">= 4.9.4"
gem 'fog-aws', group: :production
gem 'aws-sdk-s3', require: false

gem 'bootsnap', '>= 1.1.0', require: false
gem 'turbolinks'

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

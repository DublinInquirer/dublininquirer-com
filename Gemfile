source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'rails', '~> 6.1.x'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'haml'
gem 'http'
gem 'webpacker', '~> 6.0.0-beta.6'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'bcrypt'

gem 'redis'
gem 'sucker_punch'

# auth
gem 'sorcery'
gem 'pretender'

# parsing
gem 'oj'
gem 'roo' # CSV importing

gem 'sanitize'
gem 'nokogiri'
gem 'kramdown' # markdown
gem 'reverse_markdown' # used to re-display html after saving
gem 'meta-tags'
gem 'textacular' # pg search
gem 'namae'
gem 'countries'
gem 'country_select', '~> 3.1'
gem 'browser'
gem 'kaminari' # pagination
gem 'rinku'

# external services
gem 'postmark-rails'
gem 'gibbon'
gem 'stripe'
gem 'stripe_event'

# attachments
gem 'carrierwave'
gem "mini_magick"
gem 'fog-aws', group: :production
gem 'aws-sdk-s3', require: false

# cron
gem 'whenever', require: false # cron jobs

# apm
gem 'appsignal'

group :development, :test do
  gem 'rack-mini-profiler'
  gem 'stripe-ruby-mock', '~> 2.5.8', :require => 'stripe_mock'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'mocha'
  gem "standard"
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
  gem 'squasher', require: false
end

group :test do
  gem 'capybara'
  gem 'webmock'
  gem 'webdrivers', '~> 3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

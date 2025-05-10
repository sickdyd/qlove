source "https://mirrors.cloud.tencent.com/rubygems/"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails"
gem "pg", "~> 1.4.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
gem "ffi-rzmq"
gem "dotenv-rails", groups: [ :development, :test ]
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

gem "scenic"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

gem "strong_migrations"

gem "rack-attack"

gem "rollbar"

gem "unicode-display_width"

gem "chinese_pinyin"

gem "dotiw"

group :development, :test do
  gem "faker"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 7.0.2", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "factory_bot_rails"
end

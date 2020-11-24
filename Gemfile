# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.1p83'

# Utilities
gem 'rake'

gem 'database_cleaner'
group :production do
  gem 'pg'
end

# Networking
gem 'http', '~> 4.0'

# Web Application
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'rack', '~> 2' # 2.3 will fix delegateclass bug
gem 'roda', '~> 3.8'
gem 'slim', '~> 3.0'

# Validation
gem 'dry-struct', '~> 1.3'
gem 'dry-types', '~> 1.4'

# Database
gem 'hirb', '~> 0.7'
gem 'hirb-unicode'
gem 'sequel', '~> 5.38.0'

group :development, :test do
  gem 'sqlite3'
end

# Testing
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'

  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'

  gem 'headless', '~> 2.3'
  gem 'watir', '~> 6.17'
end

# Quality
group :development, :test do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end

group :development, :test do
  gem 'rerun', '~> 0.13'
end

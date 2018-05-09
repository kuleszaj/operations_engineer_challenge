source 'https://rubygems.org'

ruby '2.2.4'

group :production do
  # The most useful gem ever
  gem 'rake'

  # Webserver
  gem 'thin', '~> 1.7.0'
  gem 'nokogiri', '~> 1.8.2'

  # MySQL2 driver
  gem 'mysql2'

  # Sinatra driver
  gem 'sinatra'
  gem 'sinatra-contrib'

  # Active Record
  gem 'activesupport', '~> 4.2.7.1'
  gem 'activerecord', '~> 4.2.7.1'

  # Hash generation
  gem 'digest-murmurhash'

  # SSL for Rack
  gem 'rack-ssl'

  # Rack Flash
  gem 'rack-flash3'

  # HAML for views
  gem 'haml'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'simplecov'
end

group :development do
  gem 'pry'
  gem 'rubocop', '~> 0.49.0'
  gem 'rerun'
end

require 'rubygems'
require 'capybara/rspec'
require 'capybara/poltergeist'

require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/config/'
  add_filter '/spec/'
end

# All our specs should require 'spec_helper' (this file)

# If RACK_ENV isn't set, set it to 'test'.  Sinatra defaults to development,
# so we have to override that unless we want to set RACK_ENV=test from the
# command line when we run rake spec.  That's tedious, so do it here.
ENV['RACK_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'shoulda-matchers'
require 'rack/test'

require 'database_cleaner'

RSpec.configure do |config|
  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Rack::Test::Methods
  config.include Capybara::DSL

  Capybara.app = Sinatra::Application
  Capybara.javascript_driver = :poltergeist

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def app
  Sinatra::Application
end

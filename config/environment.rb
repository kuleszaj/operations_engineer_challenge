# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'

require 'mysql2'
require 'uri'
require 'pathname'

require 'active_record'
require 'logger'

require 'sinatra'
require 'sinatra/reloader' if development?

require 'haml'
require 'rack-flash'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

configure do
  # By default, Sinatra assumes that the root is the file that
  # calls the configure block.  Since this is not the case for us,
  # we set it manually.
  set :root, APP_ROOT.to_path
  # See: http://www.sinatrarb.com/faq.html#sessions
  enable :sessions

  # Set the views to
  set :views, File.join(Sinatra::Application.root, 'app', 'views')

  use Rack::Flash
end

configure :development do
  set :session_secret, ENV['SESSION_SECRET'] || 'development'
  set :https, false
  set :logging, Logger::DEBUG
end

configure :test do
  set :session_secret, ENV['SESSION_SECRET'] || 'test'
  set :https, false
end

configure :production do
  set :session_secret, ENV['SESSION_SECRET'] || SecureRandom.hex(64)
  set :https, true
  set :logging, Logger::INFO
end

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up libraries
Dir[APP_ROOT.join('lib', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

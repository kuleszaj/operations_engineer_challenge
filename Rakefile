require 'rake'

require ::File.expand_path('../config/environment', __FILE__)

# Include all of ActiveSupport's core class extensions, e.g., String#camelize
require 'active_support/core_ext'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts 'If you want rspec integration, be sure to '\
       'bundle install with the "test" group'
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }

namespace :app do
  desc 'Run with Rackup'
  task :run do
    Bundler.with_clean_env do
      sh 'bundle exec rackup'
    end
  end

  desc 'Run with Rerun'
  task :rerun do
    Bundler.with_clean_env do
      sh 'bundle exec rerun -b rackup'
    end
  end
end

namespace :generate do
  desc 'Create an empty model in app/models,'\
       'e.g., rake generate:model NAME=User'
  task :model do
    unless ENV.key?('NAME')
      fail 'Must specificy model name, e.g., rake generate:model NAME=User'
    end

    model_name     = ENV['NAME'].camelize
    model_filename = ENV['NAME'].underscore + '.rb'
    model_path = APP_ROOT.join('app', 'models', model_filename)

    if File.exist?(model_path)
      fail "ERROR: Model file '#{model_path}' already exists"
    end

    puts "Creating #{model_path}"
    File.open(model_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{model_name} < ActiveRecord::Base
          # Remember to create a migration!
        end
      EOF
    end
  end

  desc 'Create an empty migration in db/migrate,'\
        'e.g., rake generate:migration NAME=create_tasks'
  task :migration do
    unless ENV.key?('NAME')
      fail 'Must specificy migration name,'\
           'e.g., rake generate:migration NAME=create_tasks'
    end

    name     = ENV['NAME'].camelize
    filename = format('%s_%s.rb', Time.now.strftime('%Y%m%d%H%M%S'),
                      ENV['NAME'].underscore)
    path     = APP_ROOT.join('db', 'migrate', filename)

    fail "ERROR: File '#{path}' already exists" if File.exist?(path)

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{name} < ActiveRecord::Migration
          def change
          end
        end
      EOF
    end
  end

  desc 'Create an empty model spec in spec, e.g., rake generate:spec NAME=user'
  task :spec do
    unless ENV.key?('NAME')
      fail 'Must specificy migration name, e.g., rake generate:spec NAME=user'
    end

    name     = ENV['NAME'].camelize
    filename = format('%s_spec.rb', ENV['NAME'].underscore)
    path     = APP_ROOT.join('spec', filename)

    fail "ERROR: File '#{path}' already exists" if File.exist?(path)

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        require 'spec_helper'

        describe #{name} do
          pending "add some examples to (or delete) #{__FILE__}"
        end
      EOF
    end
  end
end

namespace :db do
  desc 'Drop, create, and migrate the database'
  task reset: [:drop, :create, :migrate]

  desc "Create the databases at #{DB_NAME}"
  task :create do
    puts 'Creating development and test databases if they don\'t exist...'
    system("mysql -u root -e 'CREATE DATABASE #{APP_NAME}_development' \
           && mysql -u root -e 'CREATE DATABASE #{APP_NAME}_test'")
  end

  desc "Drop the database at #{DB_NAME}"
  task :drop do
    puts 'Dropping development and test databases...'
    system("mysql -u root -e 'DROP DATABASE #{APP_NAME}_development' \
           && mysql -u root -e 'DROP DATABASE #{APP_NAME}_test'")
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog).'
  task :migrate do
    ActiveRecord::Migrator.migrations_paths << \
      File.dirname(__FILE__) + 'db/migrate'
    ActiveRecord::Migration.verbose = \
      ENV['VERBOSE'] ? ENV['VERBOSE'] == 'true' : true
    ActiveRecord::Migrator.migrate(
      ActiveRecord::Migrator.migrations_paths,
      ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    ) do |migration|
      ENV['SCOPE'].blank? || (ENV['SCOPE'] == migration.scope)
    end
  end

  desc 'Populate the database with dummy data by running db/seeds.rb'
  task :seed do
    require APP_ROOT.join('db', 'seeds.rb')
  end

  desc 'Returns the current schema version number'
  task :version do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  namespace :test do
    desc 'Migrate test database'
    task :prepare do
      system 'rake db:migrate RACK_ENV=test'
    end
  end
end

desc 'Start IRB with application environment loaded'
task :console do
  exec 'pry -r./config/environment'
end

task default: :spec

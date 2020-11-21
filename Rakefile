# frozen_string_literal: true

require 'rake/testtask'
require_relative './config/init'

task :default do
  puts `rake -T`
end


desc 'Run all tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Run github api test'
task :spec_github_api do
  sh 'ruby spec/gateway_github_spec.rb'
end

desc 'Run database test'
task :spec_database do
  sh 'ruby spec/gateway_database_spec.rb'
end

desc 'Run inbox domain test'
task :spec_inbox_domain do
  sh 'ruby spec/domain_inboxes_spec.rb'
end


namespace :run do
  desc 'Run Roda app in dev env'
  task :dev do
    sh 'rerun -c "rackup -p 9292"'
  end

  desc 'Run Roda app in test env'
  task :test do
    sh 'RACK_ENV=test rackup -p 9000'
  end
end

desc 'Keep restarting web app upon changes'
task :rerack do
  sh "rerun -c rackup --ignore 'coverage/*'"
end


desc 'Run application console (irb)'
task :console do
  sh 'irb -r ./init'
end

namespace :vcr do
  desc 'Delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  desc 'Run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh 'reek'
  end

  task :flog do
    sh "flog #{CODE}"
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # Load config
    require_relative 'spec/helpers/database_helper'

    def app
      MindMap::App
    end
  end

  desc 'Run Migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to the latest"
    Sequel::Migrator.run(app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    DatabaseHelper.setup_database_cleaner
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file'
  task drop: :config do
    if app.environment == :production
      puts 'Cannot remove the production database!'
      return
    end

    FileUtils.rm(MindMap::App.config.DB_FILENAME)
    puts "Deleted #{MindMap::App.config.DB_FILENAME}"
  end
end

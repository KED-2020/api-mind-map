# frozen_string_literal: true

require 'rake/testtask'
require_relative './config/init'

task :default do
  puts `rake -T`
end

namespace :spec do
  desc 'Run all tests (except for acceptance test)'
  Rake::TestTask.new(:all) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.warning = false
  end

  # NOTE: run `rake run:test` in another process
  desc 'Run acceptance test'
  Rake::TestTask.new(:accept) do |t|
    t.pattern = 'spec/tests_acceptance/*_acceptance.rb'
    t.warning = false
  end
end

namespace :respec do
  desc 'Keep rerunning unit/integration tests upon changes'
  task :all do
    sh "rerun -c 'rake spec:all' --ignore 'coverage/*'"
  end
end

namespace :rack do
  desc 'Run Roda app in dev env'
  task :dev do
    sh 'rackup -p 9292'
  end

  desc 'Run Roda app in test env'
  task :test do
    sh 'RACK_ENV=test rackup -p 9000'
  end
end

namespace :rerack do
  desc 'Keep restarting web app upon changes in dev env'
  task :dev do
    sh 'rerun -c "rackup -p 9292" --ignore "coverage/*"'
  end

  desc 'Keep restarting web app upon changes in test env'
  task :test do
    sh 'rerun -c "RACK_ENV=test rackup -p 9000" --ignore "coverage/*"'
  end
end

namespace :console do
  desc 'Run application console (irb) in dev env'
  task :dev do
    sh 'irb -r ./init'
  end

  desc 'Run application console (irb) in test env'
  task :test do
    sh 'RACK_ENV=test irb -r ./init'
  end
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

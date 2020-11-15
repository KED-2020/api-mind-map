# frozen_string_literal: true

require 'rake/testtask'
require_relative './config/init.rb'


task :default do
  puts `rake -T`
end


desc 'Run tests once'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end


desc 'Run application console (irb)'
task :console do
  sh 'irb -r ./init'
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


namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end


namespace :quality do
  CODE = 'app/'

  desc 'run all quality checks'
  task all: %i[rubocop reek flog]

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh 'reek #{CODE}'
  end

  task :flog do
    sh "flog #{CODE}"
  end
end

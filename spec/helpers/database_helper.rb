# frozen_string_literal: true

require 'database_cleaner'

# Cleans the database during a test run
class DatabaseHelper
  def self.setup_database_cleaner
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.start
  end

  def self.wipe_database
    MindMap::App.DB.run('PRAGMA foreign_keys = OFF')
    DatabaseCleaner.clean
    MindMap::App.DB.run('PRAGMA foreign_keys = ON')
  end
end

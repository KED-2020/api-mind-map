# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'delegate'

module MindMap
  # Configuration for the App
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    configure :app_test do
      require_relative '../spec/helpers/vcr_helper'

      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_github(recording: :none)
    end

    configure :production do
      # Gonna setup later when we have our production db.
    end

    configure do
      require 'sequel'

      DB = Sequel.connect(ENV['DATABASE_URL']) # rubocop:disable Lint/ConstantDefinitionInBlock

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end
  end
end

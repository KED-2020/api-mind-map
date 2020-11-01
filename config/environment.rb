# frozen_string_literal: true

require 'roda'
require 'yaml'

module MindMap
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    GH_TOKEN = CONFIG['GITHUB_TOKEN']
  end
end

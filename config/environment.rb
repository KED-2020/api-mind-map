# frozen_string_literal: true

require 'roda'
require 'econfig'

module MindMap
  # Configuration for the App
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'
  end
end

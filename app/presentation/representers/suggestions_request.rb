# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'inbox_representer'

module MindMap
  module Representer
    # Representer object for suggestions requests
    class SuggestionsRequest < Roar::Decorator
      include Roar::JSON

      property :project, extend: Representer::Inbox, class: OpenStruct
      property :id
    end
  end
end

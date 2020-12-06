# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'suggestion_representer'

module MindMap
  module Representer
    class Inbox < Roar::Decorator
      include Roar::JSON

      property :name
      property :description
      property :url
      collection :suggestions, extend: Representer::Suggestion, class: OpenStruct
    end
  end
end

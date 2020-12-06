# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MindMap
  module Representer
    class SuggestionUrl < Roar::Decorator
      include Roar::JSON

      property :html_url
    end
  end
end

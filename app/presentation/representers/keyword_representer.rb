# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MindMap
  module Representer
    class Keyword < Roar::Decorator
      include Roar::JSON

      property :id
      property :name
    end
  end
end

# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MindMap
  module Representer
    class Topic < Roar::Decorator
      include Roar::JSON

      property :name
      property :description
    end
  end
end

# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MindMap
  module Representer
    class Subscription < Roar::Decorator
      include Roar::JSON

      property :name
      property :description
      property :created_at
    end
  end
end

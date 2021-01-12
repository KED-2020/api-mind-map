# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MindMap
  module Representer
    class Suggestion < Roar::Decorator
      include Roar::JSON

      property :id
      property :name
      property :description
      property :html_url
      property :created_at
    end
  end
end

# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'keyword_representer'

module MindMap
  module Representer
    class Subscription < Roar::Decorator
      include Roar::JSON

      property :id
      property :name
      property :description
      property :created_at
      collection :keywords, extend: Representer::Keyword, class: OpenStruct
    end
  end
end

# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'topic_representer'

module MindMap
  module Representer
    class Document < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :name
      property :description
      property :html_url
      collection :topics, extend: Representer::Topic, class: OpenStruct
    end
  end
end

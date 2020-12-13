# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'topic_representer'

module MindMap
  module Representer
    # Document Representer
    class Document < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :origin_id
      property :name
      property :description
      property :html_url
      collection :topics, extend: Representer::Topic, class: OpenStruct

      link :self do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.name}"
      end
    end
  end
end

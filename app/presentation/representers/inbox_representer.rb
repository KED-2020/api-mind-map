# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'suggestion_representer'

module MindMap
  module Representer
    class Inbox < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :name
      property :description
      property :url
      collection :suggestions, extend: Representer::Suggestion, class: OpenStruct

      link :self do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.name}"
      end
    end
  end
end

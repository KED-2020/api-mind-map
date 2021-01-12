# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'suggestion_representer'
require_relative 'document_representer'
require_relative 'subscription_representer'

module MindMap
  module Representer
    # Inbox representer
    class Inbox < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :name
      property :description
      property :url
      collection :documents, extend: Representer::Document, class: OpenStruct
      collection :suggestions, extend: Representer::Suggestion, class: OpenStruct
      collection :subscriptions, extend: Representer::Subscription, class: OpenStruct

      link :self do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.name}"
      end

      link :suggestions do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.url}/suggestions"
      end

      link :documents do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.url}/documents"
      end

      link :subscriptions do
        "#{App.config.API_HOST}/api/v1/inboxes/#{represented.url}/subscriptions"
      end
    end
  end
end

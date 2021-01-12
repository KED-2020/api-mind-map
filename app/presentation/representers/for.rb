# frozen_string_literal: true

require_relative '../responses/init'
require_relative 'document_representer'
require_relative 'documents_representer'
require_relative 'inbox_representer'
require_relative 'inboxes_representer'
require_relative 'subscription_representer'
require_relative 'subscriptions_representer'
require_relative 'suggestion_representer'
require_relative 'topic_representer'
require_relative 'http_response_representer'

module MindMap
  module Representer
    # Returns appropriate representer for response object
    class For
      REP_KLASS = {
        Entity::Document => Document,
        Response::DocumentsList => DocumentsList,
        Entity::Subscription => Subscription,
        Response::SubscriptionsList => SubscriptionsList,
        Entity::Suggestion => Suggestion,
        Entity::Inbox => Inbox,
        String => HttpResponse
      }.freeze

      attr_reader :status_rep, :body_rep

      def initialize(result)
        if result.failure?
          @status_rep = Representer::HttpResponse.new(result.failure)
          @body_rep = @status_rep
        else
          value = result.value!
          @status_rep = Representer::HttpResponse.new(value)
          @body_rep = value.message.nil? ? value.message : REP_KLASS[value.message.class].new(value.message)
        end
      end

      def http_status_code
        @status_rep.http_status_code
      end

      def to_json(*args)
        @body_rep.to_json(*args)
      end

      def status_and_body(response)
        response.status = http_status_code
        to_json
      end
    end
  end
end

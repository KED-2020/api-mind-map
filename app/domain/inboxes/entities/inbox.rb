# frozen_string_literal: true

require_relative 'suggestion'
require_relative 'document'
require_relative 'subscription'

module MindMap
  module Entity
    # Aggregate root for the inboxes domain
    class Inbox < Dry::Struct
      include Dry.Types
      extend MindMap::Mixins::MnemonicsGenerator

      attribute :id, Integer.optional
      attribute :url, Strict::String
      attribute :name, Strict::String
      attribute :description, Strict::String.optional
      attribute :suggestions, Strict::Array.of(MindMap::Entity::Suggestion).optional
      attribute :documents,   Strict::Array.of(MindMap::Entity::Document).optional
      attribute :subscriptions, Strict::Array.of(MindMap::Entity::Subscription).optional

      def to_attr_hash
        to_hash.reject { |key, _| %i[id suggestions documents subscriptions].include? key }
      end

      def empty?
        suggestions.empty?
      end

      def can_request_suggestions?
        subscriptions.count.positive?
      end

      def self.new_inbox_url
        generate_mnemonics
      end
    end
  end
end

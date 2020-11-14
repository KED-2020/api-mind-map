# frozen_string_literal: false

require_relative 'suggestion'

module MindMap
  module Entity
    # Aggregate root for the inboxes domain
    class Inbox < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :url, Strict::String
      attribute :name, Strict::String
      attribute :description, Strict::String.optional
      attribute :suggestions, Strict::Array.of(MindMap::Entity::Suggestion).optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end

      def empty?
        suggestions.nil?
      end
    end
  end
end

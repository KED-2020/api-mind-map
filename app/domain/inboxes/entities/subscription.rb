# frozen_string_literal: true

require_relative 'keyword'

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Subscription < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :name, Strict::String
      attribute :description, Strict::String.optional
      attribute :inbox_id, Strict::Integer.optional
      attribute :created_at, Strict::Time.optional
      attribute :keywords, Strict::Array.of(MindMap::Entity::Keyword).optional

      def to_attr_hash
        to_hash.reject { |key, _| %i[id created_at keywords].include? key }
      end

      def valid_keywords?
        keywords&.count&.positive? && keywords.count <= 5
      end
    end
  end
end

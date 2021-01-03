# frozen_string_literal: true

require_relative 'topic'

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Document < Dry::Struct
      include Dry.Types

      attribute :id,          Integer.optional
      attribute :origin_id,   Strict::Integer
      attribute :name,        Strict::String
      attribute :description, Strict::String
      attribute :html_url,    Coercible::String
      attribute :topics,      Strict::Array.of(MindMap::Entity::Topic).optional

      def to_attr_hash
        to_hash.reject { |key, _| %i[id topics].include? key }
      end
    end
  end
end

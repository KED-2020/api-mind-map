# frozen_string_literal: false

module MindMap
  module Entity
    # Domain entity for suggestions
    class Suggestion < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :name, Strict::String
      attribute :description, Strict::String.optional
      attribute :source, Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end

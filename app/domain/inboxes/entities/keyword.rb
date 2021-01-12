# frozen_string_literal: true

module MindMap
  module Entity
    # Domain entity for a keyword
    class Keyword < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :name, Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end

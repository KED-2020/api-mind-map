# frozen_string_literal: true

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Topic < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :name, Strict::String
      attribute :description, Strict::String.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end

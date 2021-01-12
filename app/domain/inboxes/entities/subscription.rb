# frozen_string_literal: true

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

      def to_attr_hash
        to_hash.reject { |key, _| [:id, :created_at].include? key }
      end
    end
  end
end

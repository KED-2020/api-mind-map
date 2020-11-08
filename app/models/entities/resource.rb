# frozen_string_literal: false

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Resource < Dry::Struct
      include Dry.Types

      attribute :id,          Integer.optional
      attribute :origin_id,   Strict::Integer
      attribute :name,        Strict::String
      attribute :description, Strict::String
      attribute :github_url,  Coercible::String
      attribute :homepage,    Strict::String.optional
      attribute :language,    Strict::String
      attribute :topics,      Strict::Array.of(String).optional
    end
  end
end

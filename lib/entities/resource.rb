# frozen_string_literal: false

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Resource < Dry::Struct
      include Dry.Types

      attribute :name,        Strict::String
      attribute :description, Strict::String
      attribute :github_url,  Coercible::String
      attribute :homepage,    Strict::String
      attribute :language,    Strict::String
    end
  end
end

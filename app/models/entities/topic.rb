# frozen_string_literal: false

module MindMap
  module Entity
    # Domain entity for any coding projects
    class Topic < Dry::Struct
      include Dry.Types

      attribute :name, Strict::String
      attribute :description, Strict::String
    end
  end
end

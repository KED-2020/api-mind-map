# frozen_string_literal: true

require_relative 'inboxes'
require_relative 'suggestions'

module MindMap
  module Repository
    # Finds the right repository for an entity object or class
    class For
      ENTITY_REPOSITORY = {
        Entity::Inbox => Inboxes,
        Entity::Suggestion => Suggestions
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end

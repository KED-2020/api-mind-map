# frozen_string_literal: true

module MindMap
  module Repository
    # Repository for suggestions
    class Suggestions
      def self.find_id(id)
        rebuild_entity Database::DocumentOrm.first(id: id)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Suggestion.new(db_record.to_hash)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_entity|
          Suggestions.rebuild_entity(db_entity)
        end
      end

      def self.find_inbox_suggestion(suggestion_id)
        db_suggestion = Database::DocumentOrm.left_join(:inboxes_suggestions, document_id: :id)
                                             .where(document_id: suggestion_id)
                                             .first

        return nil unless db_suggestion

        rebuild_entity db_suggestion
      end

      def self.db_find_or_create(entity)
        Database::DocumentOrm.find_or_create(entity.to_attr_hash)
      end

      def self.find_or_create_by_html_url(entity)
        Database::DocumentOrm.find(html_url: entity.to_attr_hash[:html_url]) ||
          Database::DocumentOrm.create(entity.to_attr_hash)
      end
    end
  end
end

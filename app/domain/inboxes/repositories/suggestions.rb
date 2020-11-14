# frozen_string_literal: true

module MindMap
  module Repository
    # Repository for suggestions
    class Suggestions
      def self.find_id(id)
        rebuild_entity Database::SuggestionOrm.first(id: id)
      end

      private

      def self.rebuild_entity(db_record)
        return nill unless db_record

        Entity::Suggestion.new(db_record.to_hash)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_entity|
          Suggestions.rebuild_entity(db_entity)
        end
      end

      def self.db_find_or_create(entity)
        Database::SuggestionOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end

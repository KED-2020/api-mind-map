# frozen_string_literal: true

module MindMap
  module Repository
    # Repository for Keywords
    class Keywords
      def self.find_id(id)
        rebuild_entity Database::KeywordOrm.first(id: id)
      end

      def self.find_by_name(name)
        rebuild_entity Database::KeywordOrm.first(name: name)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Keyword.new(
          id: db_record.id,
          name: db_record.name
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_keyword|
          Keywords.rebuild_entity(db_keyword)
        end
      end

      def self.find_or_create(keyword)
        find_by_name(keyword.name) || Database::KeywordOrm.create(keyword.to_attr_hash)
      end
    end
  end
end

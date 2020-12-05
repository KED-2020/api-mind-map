# frozen_string_literal: true

module MindMap
  module Repository
    # Repository for Members
    class Topics
      def self.find_id(id)
        rebuild_entity Database::TopicOrm.first(id: id)
      end

      def self.find_topic_name(topic_name)
        rebuild_entity Database::TopicOrm.first(name: topic_name)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Topic.new(
          id: db_record.id,
          name:        db_record.name,
          description: db_record.description
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_topic|
          Topics.rebuild_entity(db_topic)
        end
      end

      def self.db_find_or_create(entity)
        Database::TopicOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
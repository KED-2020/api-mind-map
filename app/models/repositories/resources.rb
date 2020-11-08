# frozen_string_literal: true

module MindMap

  module Repository
    # Repository for Resource Entities
    class Resources
      def self.all
        Database::ResourceOrm.all.map { |db_resource| rebuild_entity(db_resource) }
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::ResourceOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::ResourceOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        db_resource = find(entity)

        return rebuild_entity(db_resource) if db_resource

        db_resource = PersistResource.new(entity).call

        rebuild_entity(db_resource)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Resource.new(
          db_record.to_hash.merge(
            topics: Topics.rebuild_many(db_record.topics)
          )
        )
      end

      # Helper class to persist resource and its topics to the database
      class PersistResource
        def initialize(entity)
          @entity = entity
        end

        def create_resource
          Database::ResourceOrm.create(@entity.to_attr_hash)
        end

        def call
          create_resource.tap do |db_resource|
            @entity.topics.each do |topic|
              saved_topic = Topics.db_find_or_create(topic)

              # Topics.db_find_or_create does not return an item with an id.
              db_resource.add_topic(saved_topic) if saved_topic
            end
          end
        end
      end
    end
  end
end

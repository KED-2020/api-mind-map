# frozen_string_literal: true

module MindMap

  module Repository
    # Repository for document Entities
    class Documents
      def self.all
        Database::DocumentOrm.all.map { |db_document| rebuild_entity(db_document) }
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_html_url(html_url)
        db_record = Database::DocumentOrm.first(html_url: html_url)
        rebuild_entity(db_record)
      end

      def self.find_id(id)
        db_record = Database::DocumentOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::DocumentOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        db_document = find(entity) || PersistDocument.new(entity).call
        rebuild_entity(db_document)
      end

      def self.create(entity)
        raise 'Document already exists' if find_html_url(entity.html_url)

        db_project = PersistDocument.new(entity).call
        rebuild_entity(db_project)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Document.new(
          db_record.to_hash.merge(
            topics: Topics.rebuild_many(db_record.topics)
          )
        )
      end

      # Helper class to persist document and its topics to the database
      class PersistDocument
        def initialize(entity)
          @entity = entity
        end

        def create_document
          Database::DocumentOrm.create(@entity.to_attr_hash)
        end

        def call
          create_document.tap do |db_document|
            @entity.topics.each do |topic|
              saved_topic = Topics.db_find_or_create(topic)

              # Topics.db_find_or_create does not return an item with an id.
              db_document.add_topic(saved_topic) if saved_topic
            end
          end
        end
      end
    end
  end
end

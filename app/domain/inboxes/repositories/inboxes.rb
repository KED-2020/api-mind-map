# frozen_string_literal: true

module MindMap
  module Repository
    # A repository for inboxes
    class Inboxes
      def self.all
        Database::InboxOrm.all.map { |db_project| rebuild_entity(db_project) }
      end

      def self.find_id(id)
        db_record = Database::InboxOrm.first(id: id)

        rebuild_entity(db_record)
      end

      def self.find_url(url)
        db_record = Database::InboxOrm.first(url: url)

        rebuild_entity(db_record)
      end

      def self.find_or_create(entity)
        db_inbox = find_id(entity.id) || PersistInbox.new(entity).call

        rebuild_entity(db_inbox)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Inbox.new(
          db_record.to_hash.merge(
            suggestions: Suggestions.rebuild_many(db_record.suggestions)
          )
        )
      end

      # Helper class to persist inbox and its suggestions to the database
      class PersistInbox
        def initialize(entity)
          @entity = entity
        end

        def create_inbox
          Database::InboxOrm.create(@entity.to_attr_hash)
        end

        def call
          create_inbox.tap do |db_inbox|
            @entity.suggestions.each do |suggestion|
              saved_suggestion = Suggestions.db_find_or_create(suggestion)

              db_inbox.add_suggestion(saved_suggestion) if saved_suggestion
            end
          end
        end
      end
    end
  end
end

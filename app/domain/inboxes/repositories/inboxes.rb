# frozen_string_literal: true

module MindMap
  module Repository
    # A repository for inboxes
    class Inboxes
      def self.exists(inbox_url)
        !Database::InboxOrm.first(url: inbox_url).nil?
      end

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

      def self.create(entity)
        db_inbox = find_url(entity.url) || PersistInbox.new(entity).call

        rebuild_entity(db_inbox)
      end

      def self.add_suggestions(entity, suggestions)
        return unless entity && suggestions.count.positive?

        db_inbox = PersistInboxSuggestions.new(entity, suggestions).call
        rebuild_entity(db_inbox)
      end

      def self.add_documents(inbox_id, documents)
        return unless inbox_id && documents

        db_inbox = PersistInboxDocuments.new(inbox_id, documents).call

        rebuild_entity(db_inbox)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Inbox.new(
          db_record.to_hash.merge(
            suggestions: Suggestions.rebuild_many(db_record.suggestions),
            documents: Documents.rebuild_many(db_record.documents)
          )
        )
      end

      def self.new_inbox_id
        loop do
          id = Entity::Inbox.new_inbox_id

          return id if Database::InboxOrm.first(url: id).nil?
        end
      end

      # Helper class to add suggestions to an existing inbox.
      class PersistInboxSuggestions
        def initialize(entity, suggestions)
          @entity = entity
          @suggestions = suggestions
        end

        def find_inbox
          Database::InboxOrm.first(id: @entity.id)
        end

        def call
          find_inbox.tap do |db_inbox|
            @suggestions.each do |suggestion|
              saved_suggestion = Suggestions.find_or_create_by_html_url(suggestion)

              db_inbox.add_suggestion(saved_suggestion) if saved_suggestion
            end
          end
        end
      end

      # Helper class to add documents to an existing inbox.
      class PersistInboxDocuments
        def initialize(inbox_id, documents)
          @inbox_id = inbox_id
          @documents = documents
        end

        def find_inbox
          Database::InboxOrm.first(url: @inbox_id)
        end

        def call
          find_inbox.tap do |db_inbox|
            @documents.each do |db_record|
              document = Documents.find_or_create_by_html_url(db_record)

              db_inbox.add_document(document) if document
            end
          end
        end
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
              saved_suggestion = Suggestions.find_or_create_by_html_url(suggestion)

              db_inbox.add_suggestion(saved_suggestion) if saved_suggestion
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module MindMap
  module Repository
    # Repository for suggestions
    class Subscriptions
      def self.create(entity)
        PersistSubscription.new(entity).call
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Subscription.new(
          db_record.to_hash.merge(
            name: db_record.name,
            description: db_record.description,
            inbox_id: db_record.inbox_id,
            created_at: db_record.created_at,
            keywords: Keywords.rebuild_many(db_record.keywords)
          )
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_member|
          Subscriptions.rebuild_entity(db_member)
        end
      end

      # Helper class to persist a subscription to the database
      class PersistSubscription
        def initialize(entity)
          @entity = entity
        end

        def create_subscription
          Database::SubscriptionOrm.create(@entity.to_attr_hash)
        end

        def call
          create_subscription.tap do |subscription|
            @entity.keywords.each do |keyword|
              saved_keyword = Keywords.find_or_create(keyword)

              subscription.add_keyword saved_keyword if saved_keyword
            end
          end
        end
      end
    end
  end
end

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
            created_at: db_record.created_at
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

        def call
          Database::SubscriptionOrm.create(@entity.to_attr_hash)
        end
      end
    end
  end
end

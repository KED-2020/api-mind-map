# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # ORM for subscriptions
    class SubscriptionOrm < Sequel::Model(:subscriptions)
      many_to_one :inbox,
                  class: :'MindMap::Database::InboxOrm'

      many_to_many :keywords,
                   class: :'MindMap::Database::KeywordOrm',
                   join_table: :subscriptions_keywords,
                   left_key: :subscription_id, right_key: :keyword_id

      plugin :timestamps, update_on_create: true
    end
  end
end

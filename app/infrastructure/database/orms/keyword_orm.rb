# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for Keywords
    class KeywordOrm < Sequel::Model(:keywords)
      many_to_many :subscriptions,
                   class: :'MindMap::Database::SubscriptionOrm',
                   join_table: :subscriptions_keywords,
                   left_key: :keyword_id, right_key: :subscription_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(keyword_info)
        first(name: keyword_info[:name].lowercase) || create(keyword_info)
      end
    end
  end
end

# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # ORM for subscriptions
    class SubscriptionOrm < Sequel::Model(:subscriptions)
      many_to_one :inbox,
                  class: :'MindMap::Database::InboxOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end

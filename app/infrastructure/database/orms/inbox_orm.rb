# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for inboxes
    class InboxOrm < Sequel::Model(:inboxes)
      many_to_many :suggestions,
                   class: :'MindMap::Database::DocumentOrm',
                   join_table: :inboxes_suggestions,
                   left_key: :inbox_id, right_key: :document_id

      many_to_many :documents,
                   class: :'MindMap::Database::DocumentOrm',
                   join_table: :inboxes_documents,
                   left_key: :inbox_id, right_key: :document_id

      one_to_many :subscriptions,
                  class: :'MindMap::Database::SubscriptionOrm',
                  key: :inbox_id

      plugin :timestamps, update_on_create: true
    end
  end
end

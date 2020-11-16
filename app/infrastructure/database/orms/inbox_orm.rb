# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for inboxes
    class InboxOrm < Sequel::Model(:inboxes)
      many_to_many :suggestions,
                   class: :'MindMap::Database::SuggestionOrm',
                   join_table: :inboxes_suggestions,
                   left_key: :inbox_id, right_key: :suggestion_id

      plugin :timestamps, update_on_create: true
    end
  end
end

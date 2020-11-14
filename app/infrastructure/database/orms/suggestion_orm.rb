# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for suggestions
    class SuggestionOrm < Sequel::Model(:suggestions)
      many_to_many :inboxes,
                   class: :'MindMap::Database::InboxOrm',
                   join_table: :inboxes_suggestions,
                   left_key: :suggestion_id, right_key: :inbox_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(suggestion_info)
        # First or Create
        create(suggestion_info)
      end
    end
  end
end

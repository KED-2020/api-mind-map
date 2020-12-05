# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for documents
    class DocumentOrm < Sequel::Model(:documents)
      many_to_many :topics,
                   class: :'MindMap::Database::TopicOrm',
                   join_table: :documents_topics,
                   left_key: :document_id, right_key: :topic_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(document_info)
        create(document_info)
      end
    end
  end
end

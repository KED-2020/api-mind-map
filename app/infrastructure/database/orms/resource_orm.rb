# frozen_string_literal: true

require 'sequel'

module MindMap
  module Database
    # Object Relational Mapper for resources
    class ResourceOrm < Sequel::Model(:resources)
      many_to_many :topics,
                   class: :'MindMap::Database::TopicOrm',
                   join_table: :resources_topics,
                   left_key: :resource_id, right_key: :topic_id

      plugin :timestamps, update_on_create: true
    end
  end
end

# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:resources_topics) do
      primary_key %i[resource_id topic_id]
      foreign_key :resource_id, :resources
      foreign_key :topic_id, :topics

      index %i[resource_id topic_id]
    end
  end
end

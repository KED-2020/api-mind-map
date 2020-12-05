# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:documents_topics) do
      primary_key %i[document_id topic_id]
      foreign_key :document_id, :documents
      foreign_key :topic_id, :topics

      index %i[document_id topic_id]
    end
  end
end

# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:inboxes_suggestions) do
      primary_key %i[inbox_id document_id]
      foreign_key :inbox_id, :inboxes
      foreign_key :document_id, :documents

      index %i[inbox_id document_id]
    end
  end
end

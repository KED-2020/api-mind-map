# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:inboxes_suggestions) do
      primary_key %i[inbox_id suggestion_id]
      foreign_key :inbox_id, :inboxes
      foreign_key :suggestion_id, :suggestions

      index %i[inbox_id suggestion_id]
    end
  end
end

# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:subscriptions) do
      primary_key :id
      foreign_key :inbox_id, :inboxes

      String :name, null: false
      String :description, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

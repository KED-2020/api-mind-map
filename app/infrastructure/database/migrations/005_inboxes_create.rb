# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:inboxes) do
      primary_key :id

      String :url, unique: true, null: false
      String :name, null: false
      String :description

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

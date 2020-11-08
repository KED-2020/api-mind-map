# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:topics) do
      primary_key :id

      String :name, unique: true
      String :description

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

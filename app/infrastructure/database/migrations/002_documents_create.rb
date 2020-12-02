# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:documents) do
      primary_key :id

      Integer :origin_id, unique: true
      String :name
      String :description
      String :html_url, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

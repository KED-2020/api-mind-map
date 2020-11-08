# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:resources) do
      primary_key :id

      Integer :origin_id, unique: true
      String :name, unique: true
      String :description
      String :homepage
      String :github_url
      String :language

      DateTime :created_at
      DateTime :updated_at
    end
  end
end

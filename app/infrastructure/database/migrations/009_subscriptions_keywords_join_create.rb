# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:subscriptions_keywords) do
      primary_key %i[subscription_id keyword_id]
      foreign_key :subscription_id, :subscriptions
      foreign_key :keyword_id, :keywords

      index %i[subscription_id keyword_id]
    end
  end
end

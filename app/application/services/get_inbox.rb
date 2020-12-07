# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Get an inbox with their contributions
    class GetInbox
      include Dry::Transaction

      step :get_inbox
      step :get_suggestions
      step :add_suggestions_to_inbox

      private

      DB_ERROR_MSG = 'Could not access database.'
      GH_ERROR_MSG = 'Having trouble receiving the suggestion.'

      def get_inbox(input)
        input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox).find_url(input[:inbox_id])
      rescue StandardError
        Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG)
      end

      def get_suggestions(input)
        input[:suggestions] = Mapper::Inbox.new(App.config.GITHUB_TOKEN).suggestions || []

        Success(input)
      rescue StandardError
        Response::ApiResult.new(status: :not_found, message: GH_ERROR_MSG)
      end

      def add_suggestions_to_inbox(input)
        Repository::Inbox::For.klass(Entity::Inbox).add_suggestions(input[:inbox], input[:suggestions])

        Response::Inbox.new(input[:inbox])
          .then { |inbox| Success(Response::ApiResult.new(status: :ok, message: inbox))}
      rescue StandardError
        Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG)
      end
    end
  end
end

# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Service to remove a suggestion from an inbox
    class DeleteInboxSuggestion
      include Dry::Transaction

      step :verify_inbox_exists
      step :delete_inbox_suggestion

      private

      INBOX_NOT_FOUND_MSG = 'Could not find inbox with the given id.'
      SUGGESTION_NOT_FOUND_MSG = 'Could not delete the requested suggestion.'
      DB_ERROR_MSG = 'Could not access database.'

      def verify_inbox_exists(input)
        if Repository::For.klass(Entity::Inbox).exists(input[:inbox_id])
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: INBOX_NOT_FOUND_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def delete_inbox_suggestion(input)
        Repository::For.klass(Entity::Inbox)
                       .remove_suggestion(input[:inbox_id], input[:suggestion_id])

        Success(Response::ApiResult.new(status: :no_content, message: nil))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

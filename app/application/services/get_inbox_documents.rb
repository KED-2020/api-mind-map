# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Loads saved documents that belong to an inbox
    class GetInboxDocuments
      include Dry::Transaction

      step :validate_inbox_url
      step :retrieve_documents

      private

      DB_ERR = 'Cannot access database'

      def validate_inbox_url(input)
        if (inbox = Repository::For.klass(Entity::Inbox).find_by_url(input[:inbox_url]))
          Success(input.merge!(inbox: inbox))
        else
          Failure('Could not find an inbox with the given id.')
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def retrieve_documents(input)
        Response::DocumentsList.new(input[:inbox].documents)
                               .then { |list| Success(Response::ApiResult.new(status: :ok, message: list)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end

# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Load the subscriptions that belong to an inbox
    class GetInboxSubscriptions
      include Dry::Transaction

      step :validate_inbox_url
      step :retrieve_subscriptions

      private

      DB_ERROR = 'Cannot access database'

      def validate_inbox_url(input)
        if (inbox = Repository::For.klass(Entity::Inbox).find_by_url(input[:inbox_url]))
          Success(input.merge!(inbox: inbox))
        else
          Failure('Could not find an inbox with the given id.')
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR))
      end

      def retrieve_subscriptions(input)
        Response::SubscriptionsList.new(input[:inbox].subscriptions)
                                   .then { |list| Success(Response::ApiResult.new(status: :ok, message: list)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR))
      end
    end
  end
end

# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Adds a subscription to an inbox
    class AddSubscription
      include Dry::Transaction

      step :validate_params
      step :find_inbox
      step :create_subscription
      step :verify_subscription
      step :store_subscription

      private

      INBOX_NOT_FOUND_MSG = 'No inbox with the given `url` exists.'
      DB_ERROR_MSG = 'Having trouble accessing the database.'

      def validate_params(input)
        params = input[:params].call

        if params.success?
          Success(input.merge(params: params.value!))
        else
          Failure(params.failure)
        end
      end

      def find_inbox(input)
        inbox = Repository::For.klass(Entity::Inbox).find_by_url(input[:params]['inbox_url'])

        if inbox
          Success(input.merge(inbox: inbox))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: INBOX_NOT_FOUND_MSG))
        end
      end

      # rubocop:disable Metrics/MethodLength
      def create_subscription(input)
        keywords = input[:params]['keywords'].map do |keyword|
          Entity::Keyword.new(id: nil, name: keyword.downcase)
        end

        subscription = Entity::Subscription.new(
          id: nil,
          name: input[:params]['name'],
          description: input[:params]['description'],
          inbox_id: input[:inbox].id,
          created_at: nil,
          keywords: keywords
        )

        Success(input.merge(subscription: subscription))
      end
      # rubocop:enable Metrics/MethodLength

      def verify_subscription(input)
        if input[:subscription].valid_keywords?
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :bad_request,
                                          message: 'We need at least `1` keyword and a max of `5`.'))
        end
      end

      def store_subscription(input)
        inbox = Repository::For.klass(Entity::Inbox)
                               .add_subscriptions(input[:inbox].url, [input[:subscription]])

        Success(Response::ApiResult.new(status: :created, message: inbox.subscriptions.last))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

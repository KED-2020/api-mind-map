# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Get an inbox with their contributions
    class GetInbox
      include Dry::Transaction

      step :validate_inbox_url
      step :find_inbox
      step :request_suggestions
      step :add_suggestions_to_inbox

      private

      NOT_FOUND_MSG = 'Could not find inbox with the given id.'
      DB_ERROR_MSG = 'Could not access database.'
      GH_ERROR_MSG = 'Having trouble receiving the suggestion.'
      NO_SUGGESTIONS_MSG = 'You need to add a subscription before you can receive suggestions.'

      def validate_inbox_url(input)
        inbox_url = input[:inbox_url].call

        return Failure(inbox_url.failure) unless inbox_url.success?

        Success(input.merge(inbox_url: inbox_url.value!))
      end

      def find_inbox(input)
        input[:inbox] = Repository::For.klass(Entity::Inbox).find_by_url(input[:inbox_url])

        if input[:inbox].nil?
          Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND_MSG))
        else
          Success(input)
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def request_suggestions(input)
        return Success(input) if input[:inbox].suggestions.count.positive?

        if input[:inbox].can_request_suggestions?
          Messaging::Queue.new(App.config.SUGGESTIONS_QUEUE_URL, App.config)
                          .send(suggestions_request_json(input))

          Failure(Response::ApiResult.new(status: :processing,
                                          message: { request_id: input[:request_id] }))
        else
          Failure(Response::ApiResult.new(status: :forbidden, message: NO_SUGGESTIONS_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: GH_ERROR_MSG))
      end

      def add_suggestions_to_inbox(input)
        # # Don't add suggestions if they exist
        # if input[:inbox].suggestions.count.zero?
        #   input[:inbox] = Repository::For.klass(Entity::Inbox)
        #                                  .add_suggestions(input[:inbox], input[:suggestions])
        # end

        Success(Response::ApiResult.new(status: :created, message: input[:inbox]))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end

      def suggestions_request_json(input)
        Response::CloneRequest.new(input[:inbox], input[:request_id])
                              .then { Representer::SuggestionsRequest.new(_1) }
                              .then(&:to_json)
      end
    end
  end
end

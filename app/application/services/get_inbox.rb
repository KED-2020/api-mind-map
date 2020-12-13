# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Get an inbox with their contributions
    class GetInbox
      include Dry::Transaction

      step :validate_inbox_id
      step :find_inbox
      step :get_suggestions
      step :add_suggestions_to_inbox

      private

      NOT_FOUND_MSG = 'Could not find inbox with the given id.'
      DB_ERROR_MSG = 'Could not access database.'
      GH_ERROR_MSG = 'Having trouble receiving the suggestion.'

      def validate_inbox_id(input)
        inbox_id = input[:inbox_id].call

        return Failure(inbox_id.failure) unless inbox_id.success?

        Success(input.merge(inbox_id: inbox_id.value!))
      end

      def find_inbox(input)
        input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox).find_url(input[:inbox_id])

        if input[:inbox].nil?
          Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND_MSG))
        else
          Success(input)
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def get_suggestions(input)
        input[:suggestions] = Mapper::Inbox.new(App.config.GITHUB_TOKEN).suggestions || []

        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: GH_ERROR_MSG))
      end

      def add_suggestions_to_inbox(input)
        # Don't add suggestions if they exist
        if input[:inbox].suggestions.count.nil?
          input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox)
                                                .add_suggestions(input[:inbox], input[:suggestions])
        end

        Success(Response::ApiResult.new(status: :created, message: input[:inbox]))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

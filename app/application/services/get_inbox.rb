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

      DB_ERROR_MSG = 'Could not access database.'
      GH_ERROR_MSG = 'Having trouble receiving the suggestion.'

      def validate_inbox_id(input)
        inbox_id = input[:inbox_id].call

        return Failure(inbox_id.failure) unless inbox_id.success?

        Success(input.merge(inbox_id: inbox_id.value!))
      end

      def find_inbox(input)
        input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox).find_url(input[:inbox_id])

        throw DB_ERROR_MSG if input[:inbox].nil?

        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.message))
      end

      def get_suggestions(input)
        input[:suggestions] = Mapper::Inbox.new(App.config.GITHUB_TOKEN).suggestions || []

        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: GH_ERROR_MSG))
      end

      def add_suggestions_to_inbox(input)
        input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox).add_suggestions(input[:inbox], input[:suggestions])

        Success(Response::ApiResult.new(status: :created, message: input[:inbox]))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

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

      def get_inbox(input)
        Repository::Inbox::For.klass(Entity::Inbox).find_url(input[:inbox_id])
                              .then { |inbox| Response::Inbox.new(inbox) }
                              .then { |inbox_id| Sucess(Response::ApiResult.new(status: :ok, message:inbox_id)) }
      rescue StandardError
        Failure('Having trouble accessing the database')
      end

      def get_suggestions(input)
        input[:suggestions] = Mapper::Inbox.new(App.config.GITHUB_TOKEN).suggestions || []

        Success(input)
      rescue StandardError
        Failure('Having trouble receiving the suggestion')
      end

      def add_suggestions_to_inbox(input)
        input[:inbox] = Repository::Inbox::For.klass(Entity::Inbox).add_suggestions(input[:inbox], input[:suggestions])
        input[:suggestions] = input[:inbox].suggestions

        Success(input)
      rescue StandardError
        Failure('Having trouble saving the suggestions to an inbox')
      end
    end
  end
end

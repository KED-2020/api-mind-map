# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Adds an inbox to the database
    class AddInbox
      include Dry::Transaction

      step :validate_params
      step :ensure_inbox_is_unique
      step :map_params_to_entity
      step :store_inbox

      private

      INBOX_ALREADY_EXISTS_MSG = 'An inbox with the given url already exists.'
      DB_ERROR_MSG = 'Having trouble accessing the database.'

      def validate_params(input)
        params = input[:params].call

        if params.success?
          Success(input.merge(params: params.value!))
        else
          Failure(params.failure)
        end
      end

      def ensure_inbox_is_unique(input)
        saved_inbox = MindMap::Repository::For.klass(Entity::Inbox).find_url(input[:params]['url'])

        if saved_inbox.nil?
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :cannot_process, message: INBOX_ALREADY_EXISTS_MSG))
        end
      end

      def map_params_to_entity(input)
        Success(input.merge(inbox: MindMap::Entity::Inbox.new(
          id: nil,
          name: input[:params]['name'],
          description: input[:params]['description'],
          url: input[:params]['url'],
          suggestions: []
        )))
      end

      def store_inbox(input)
        inbox = MindMap::Repository::For.klass(Entity::Inbox).create(input[:inbox])

        Success(Response::ApiResult.new(status: :created, message: inbox))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

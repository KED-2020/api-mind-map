# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    # Gets a new inbox ID.
    class GetNewInboxId
      include Dry::Monads::Result::Mixin

      DB_ERROR_MSG = 'Could not access database'
      GENERATE_ERROR = 'Could not generate a unique inbox id'

      def call
        if (inbox_id = Repository::For.klass(Entity::Inbox).new_inbox_id)
          Success(Response::ApiResult.new(status: :ok, message: inbox_id))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: GENERATE_ERROR))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

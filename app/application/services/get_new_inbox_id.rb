# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    # Gets a new Inbox URL.
    class GetNewInboxUrl
      include Dry::Monads::Result::Mixin

      DB_ERROR_MSG = 'Could not access database'
      GENERATE_ERROR = 'Could not generate a unique inbox id'

      def call
        if (inbox_url = Repository::For.klass(Entity::Inbox).new_inbox_url)
          Success(Response::ApiResult.new(status: :ok, message: inbox_url))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: GENERATE_ERROR))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

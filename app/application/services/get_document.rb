# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    # Module to get a document
    class GetDocument
      include Dry::Monads::Result::Mixin

      DB_ERROR_MSG = 'Could not access database.'
      NOT_FOUND_MSG = 'Could not find document with the given id.'

      def call(input)
        if (document = Repository::For.klass(Entity::Document).find_id(input[:document_id]))
          Success(Response::ApiResult.new(status: :ok, message: document))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

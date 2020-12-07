# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    # Module to get a document
    class GetDocument
      include Dry::Monads::Result::Mixin

      DB_ERROR_MSG = 'Could not access database.'

      def call(id)
        Repository::For.klass(Entity::Document)
                       .find_id(id)
                       .then { |document| Response::Document.new(document) }
                       .then { |document| Success(Response::ApiResult.new(status: :ok, message: document)) }
      rescue StandardError
        Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG)
      end
    end
  end
end

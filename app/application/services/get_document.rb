# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    class GetDocument
      include Dry::Monads::Result::Mixin

      def call(id)
        Repository::For.klass(Entity::Document)
                       .find_id(id)
                       .then { |document| Response::Document.new(document) }
                       .then { |id| Sucess(Response::ApiResult.new(status: :ok, message: id)) }
      rescue StandardError
        Failure('Could not access database')
      end
    end
  end
end
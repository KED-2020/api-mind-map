# frozen_string_literal: true

require 'dry/monads'

module MindMap
  module Service
    class GetDocument
      include Dry::Monads::Result::Mixin

      def call(id)
        document = Repository::For.klass(Entity::Document)
          .find_id(id)

        Success(document)
      rescue StandardError
        Failure('Could not access database')
      end
    end
  end
end
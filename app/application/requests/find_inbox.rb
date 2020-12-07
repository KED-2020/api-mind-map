# frozen_string_litral: true

require 'base64'
require 'dry/monads/result'
require 'json'

module MindMap
  module Request
    # Inbox request parser
    class EncodedInboxId
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming inbox requests
      def call
        Success(
          JSON.parse(decode(@params['inbox_id']))
        )
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Inbox id not found'
          )
        )
      end
    end
  end
end

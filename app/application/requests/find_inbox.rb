# frozen_string_literal: true

require 'base64'
require 'dry/monads/result'
require 'json'

module MindMap
  module Request
    # Inbox request parser
    class EncodedInboxId
      include Dry::Monads::Result::Mixin

      def initialize(inbox_id)
        @inbox_id = inbox_id
      end

      # Use in API to parse incoming inbox requests
      def call
        throw 'Inbox Id not found' if @inbox_id.nil?

        Success(@inbox_id)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :bad_request, message: e.message))
      end
    end
  end
end

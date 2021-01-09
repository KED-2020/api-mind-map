# frozen_string_literal: true

require 'base64'
require 'dry/monads/result'
require 'json'

module MindMap
  module Request
    # Inbox request parser
    class EncodedInboxId
      include Dry::Monads::Result::Mixin

      def initialize(inbox_url)
        @inbox_url = inbox_url
      end

      # Use in API to parse incoming inbox requests
      def call
        throw 'Inbox URL not found' if @inbox_url.nil?

        Success(@inbox_url)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :bad_request, message: e.message))
      end
    end
  end
end

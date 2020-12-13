# frozen_string_literal: true

require 'json'
require 'dry/monads/result'

module MindMap
  module Request
    # Create inbox request parser
    class AddInbox
      include Dry::Monads::Result::Mixin

      ID_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      INVALID_ID = 'Unsupported url format provided.'

      def initialize(params)
        @params = params
      end

      def call
        if ID_REGEX.match?(@params['url'].downcase)
          Success(@params)
        else
          Failure(
            Response::ApiResult.new(status: :bad_request, message: INVALID_ID)
          )
        end
      end
    end
  end
end

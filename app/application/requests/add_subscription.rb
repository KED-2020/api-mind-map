# frozen_string_literal: true

require 'json'
require 'dry/monads/result'

module MindMap
  module Request
    # Create inbox request parser
    class AddSubscription
      include Dry::Monads::Result::Mixin

      INBOX_URL_REGEX = /([a-zA-Z]+)-([a-zA-Z]+)-([a-zA-Z]+)/.freeze

      INVALID_ID = 'Unsupported inbox url format provided.'
      MISSING_PARAMS = '`name` and `description` are required.'

      def initialize(params)
        @params = params
      end

      def call
        if @params['name'].nil? || @params['description'].nil?
          return Failure(Response::ApiResult.new(status: :bad_request, message: MISSING_PARAMS))
        end

        if INBOX_URL_REGEX.match?(@params['inbox_url'].downcase)
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

# frozen_string_literal: true

require 'base64'
require 'dry/monads/result'
require 'json'

module MindMap
  module Request
    # Project list request parser
    class EncodedKeywordList
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming list requests
      def call
        Success(
          JSON.parse(decode(@params['keywords']))
        )
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Keywords not found'
          )
        )
      end

      # Decode params
      def decode(param)
        Base64.urlsafe_decode64(param)
      end

      # Client App will encode params to send as a string
      # - Use this method to create encoded params for testing
      def self.to_encoded(keywords)
        Base64.urlsafe_encode64(keywords.to_json)
      end

      # Use in tests to create a KeywordList object from a list
      def self.to_request(keywords)
        EncodedProjectList.new('keywords' => to_encoded(keywords))
      end
    end
  end
end

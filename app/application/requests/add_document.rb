# frozen_string_literal: true

require 'uri'
require 'json'
require 'dry/monads/result'

module MindMap
  module Request
    # Ensures that only supported links can be added as documents.
    class AddDocument
      include Dry::Monads::Result::Mixin

      URL_REGEX = %r{(http[s]?)\:\/\/(www.)?github\.com\/.*\/.*}.freeze

      INVALID_URL = 'Unsupported link to document provided'

      def initialize(params)
        @params = params
      end

      def call
        url = URI.parse(@params['html_url'])

        throw INVALID_URL unless url.host == 'github.com' && URL_REGEX.match?(url.to_s)

        Success(url.to_s)
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: INVALID_URL
          )
        )
      end
    end
  end
end

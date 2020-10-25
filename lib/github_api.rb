# frozen_string_literal: true

require 'http'
require_relative 'resource'
require_relative 'topic'

module MindMap
  # A GitHub client library.
  class GitHubApi
    SEARCH_REPO_PATH = 'https://api.github.com/search/repositories'

    def initialize(token)
      @token = token
    end

    def resource(query, topics)
      resource_response = Request.new(SEARCH_REPO_PATH, @token)
                                 .search(query, topics).parse

      # To keep things a bit simple, we take the first result from
      # the search results. We will extend this later on to allow
      # the user to select which resource they want to select.
      MindMap::Resource.new(resource_response['items'][0], self)
    end

    # Sends out HTTP requests to Github
    class Request
      def initialize(resource_root, token)
        @resource_root = resource_root
        @token = token
      end

      def search(query, topics)
        q = "#{query}#{Topic.topics_to_query_string(topics)}"

        get(@resource_root, { q: q })
      end

      def get(url, params = {})
        http_response = HTTP.headers(
          'Accept' => 'application/vnd.github.mercy-preview+json',
          'Authorization' => "token #{@token}"
        ).get(url, params: params)

        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end
      end
    end

    # Decorates HTTP responses from Github with success/error.
    # Extends Response class found here: https://github.com/ISS-SOA/soa2020-demo-project
    class Response < SimpleDelegator
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)
      UnprocessableEntity = Class.new(StandardError)

      HTTP_ERROR = {
        401 => Unauthorized,
        404 => NotFound,
        422 => UnprocessableEntity
      }.freeze

      def successful?
        HTTP_ERROR.keys.include?(code) ? false : true
      end

      def error
        HTTP_ERROR[code]
      end
    end
  end
end

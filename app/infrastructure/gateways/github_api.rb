# frozen_string_literal: true

require 'http'

module MindMap
  module Github
    # Library for Github Web API
    class Api
      def initialize(token)
        @token = token
      end

      def suggestions(topic)
        Request.new(@token).search(topic, []).parse
      end

      def search_data(query, topics)
        Request.new(@token).search(query, topics).parse
      end

      def find_project(project)
        Request.new(@token).find_project(project).parse
      end

      # Sends out HTTP requests to Github
      # :reek:FeatureEnvy
      class Request
        SEARCH_REPO_PATH = 'https://api.github.com/search/repositories'
        REPO_PATH = 'https://api.github.com/repos/'

        def initialize(token)
          @token = token
        end

        def find_project(project)
          get(REPO_PATH + project)
        end

        def search(query, topics)
          topics_to_query_string =
            if topics.length.zero?
              ''
            else
              topics.reduce('') { |reduced_query, reduced_topic| "#{reduced_query} topic:#{reduced_topic}" }
            end

          query_str = "#{query}#{topics_to_query_string}"

          get(SEARCH_REPO_PATH, { q: query_str })
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
        # The Dummy class is responsible for ...
        Unauthorized = Class.new(StandardError)

        # The Dummy class is responsible for ...
        NotFound = Class.new(StandardError)

        # The Dummy class is responsible for ...
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
end

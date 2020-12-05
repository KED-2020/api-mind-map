# frozen_string_literal: true

module MindMap
  module Mapper
    # Basic suggestion loading from github
    class GithubSuggestions
      attr_reader :gh_token
      attr_reader :gateway_class
      attr_reader :gateway
      attr_reader :topic

      def initialize(gh_token, gateway_class = Github::Api)
        @token = gh_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
        @topic = topic
      end

      def suggestions(topic)
        @gateway.suggestions(topic)['items']&.map do |suggestion|
          DataMapper.new(suggestion).build_entity
        end
      end

      # Extracts suggestions from Github
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          return nil unless @data

          MindMap::Entity::Suggestion.new(
            id: nil,
            name: name,
            description: description,
            html_url: html_url,
            created_at: Time.now
          )
        end

        def name
          @data['name']
        end

        def description
          @data['description']
        end

        def html_url
          @data['html_url']
        end
      end
    end
  end
end

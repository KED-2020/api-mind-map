# frozen_string_literal: false

module MindMap
  module Github
    # Data Mapper: Github search -> Resource entity
    class ResourceMapper
      def initialize(gh_token, gateway_class = Github::Api)
        @token = gh_token
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@token)
      end

      def search(query, topics)
        data = @gateway.search_data(query, topics)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data, @token, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, gateway_class)
          @data = data
        end

        def build_entity
          MindMap::Entity::Resource.new(
            name: name,
            description: description,
            github_url: github_url,
            homepage: homepage,
            language: language
          )
        end

        def name
          @data['items'][0]['name']
        end

        def description
          @data['items'][0]['description']
        end

        def github_url
          @data['items'][0]['github_url']
        end

        def homepage
          @data['items'][0]['homepage']
        end

        def language
          @data['items'][0]['language']
        end

      end
    end
  end
end

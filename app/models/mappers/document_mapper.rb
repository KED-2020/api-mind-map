# frozen_string_literal: false

require_relative '../entities/topic'

module MindMap
  module Github
    # Data Mapper: Github search -> Document entity
    class DocumentMapper
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
        def initialize(data, _token, _gateway_class)
          @data = data
        end

        # rubocop:disable Metrics/MethodLength
        def build_entity
          return nil unless @data['items'][0]

          MindMap::Entity::Document.new(
            id: nil,
            name: name,
            origin_id: origin_id,
            description: description,
            html_url: html_url,
            topics: topics
          )
        end
        # rubocop:enable Metrics/MethodLength

        # To keep things a bit simple, we take the first result from
        # the search results. We will extend this later on to allow
        # the user to select which document they want to select.
        def name
          @data['items'][0]['name']
        end

        def origin_id
          @data['items'][0]['id']
        end

        def description
          @data['items'][0]['description']
        end

        def html_url
          @data['items'][0]['html_url']
        end

        def topics
          @data['items'][0]['topics']&.map do |topic|
            MindMap::Entity::Topic.new(
              id: nil,
              name: topic,
              description: nil
            )
          end
        end
      end
    end
  end
end

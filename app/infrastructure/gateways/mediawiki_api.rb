# frozen_string_literal: true

require 'mediawiki_api'

module MindMap
  module Mediawiki
    # Library for Medidawiki API
    class Api
      API_PATH = 'https://en.wikipedia.org/w/api.php'
      def initialize() end

      def suggestions(topics)
        # Expect returning titile
        Request.new(API_PATH).query titles: [topics]
      end

      def search_data(topics)
        # Exepect returning content
        Request.new(API_PATH).get_wikitext topics
      end

      def find_uri(titile)
        # Expect returning title's uri
        Request.new(API_PATH).prop :info, titiles: titile
      end

      class Request < MediawikiApi::Client
      end
    end
  end
end

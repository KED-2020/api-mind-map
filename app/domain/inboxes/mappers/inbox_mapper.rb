# frozen_string_literal: true

module MindMap
  module Mapper
    # Inbox for managing inbox services.
    class Inbox
      def initialize(gh_token)
        @gh_token = gh_token
      end

      def suggestions
        Mapper::GithubSuggestions.new(@gh_token).suggestions('tensorflow')
        # Mapper::GithubSuggestions.new(@gh_token).suggestions('transformers')
      end

      def no_suggestions
        Mapper::GithubSuggestions.new(@gh_token).suggestions('1')
      end
    end
  end
end

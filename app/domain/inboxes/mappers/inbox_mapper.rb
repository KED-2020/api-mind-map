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

      def get_suggestions(inbox)
        all = []

        inbox.subscriptions.each do |sub|
          sub.keywords.each do |keyword|
            all.push(Mapper::GithubSuggestions.new(@gh_token).suggestions(keyword.name))
          end
        end

        all.flatten
      end

      def no_suggestions
        Mapper::GithubSuggestions.new(@gh_token).suggestions('1')
      end
    end
  end
end

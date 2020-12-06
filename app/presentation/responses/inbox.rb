# frozen_string_literal: true

require_relative 'suggestions_list'

module Views
  # View for a single inbox
  class Inbox
    def initialize(inbox, suggestions)
      @inbox = inbox
    end

    def entity
      @inbox
    end

    def name
      @inbox.name
    end

    def description
      @inbox.description
    end

    def url
      @inbox.url
    end

    def suggestions
      SuggestionsList.new(@inbox.suggestions)
    end

    def num_suggestions
      @inbox.suggestions.count
    end
  end
end

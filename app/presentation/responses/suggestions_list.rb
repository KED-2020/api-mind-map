# frozen_string_literal: true

require_relative 'suggestion'

module Views
   # View for a list of contributions entities
  class SuggestionsList
    def initialize(suggestions)
      @suggestions = suggestions.map.with_index { |suggestion, i| Suggestion.new(suggestion, i) }
    end

    def each
      @suggestions.each do |suggestion|
        yield suggestion
      end
    end

    def any?
      @suggestions.any?
    end
  end
end

# frozen_string_literal: true

module Views
  # View for a single suggestion entity
  class Suggestion
    def initialize(suggestion, index = nil)
      @suggestion = suggestion
      @index = index
    end

    def entity
      @suggestion
    end

    def index_str
      "suggestion[#{@index}]"
    end

    def name
      @suggestion.name
    end

    def description
      @suggestion.description
    end

    def date
      @suggestion.suggested_date
    end

    def source_url
      @suggestion.source
    end
  end
end

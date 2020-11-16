# frozen_string_literal: true

require 'delegate'

module MindMap
  module Value
    # Useful actions to do to a suggestion's source.
    class SuggestionSource < SimpleDelegator
      def initialize
        super
      end

      def pretty_print(url)
        URI.parse(url).host.gsub(/^www\./, '')
      end
    end
  end
end

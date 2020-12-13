# frozen_string_literal: true

require 'uri'
require 'delegate'
module MindMap
  module Value
    # Useful actions to do to a suggestion's html_url.
    class SuggestionUrl < SimpleDelegator
      def pretty_print(url)
        URI.parse(url).host.gsub(/^www\./, '')
      end
    end
  end
end

# frozen_string_literal: true

require 'URI'
require 'dry-validation'

module MindMap
  module Forms
    # Ensure that the link they use to add item is a url.
    class AddDocument < Dry::Validation::Contract
      URL_REGEX = %r{(http[s]?)\:\/\/(www.)?github\.com\/.*\/.*}.freeze

      params do
        required(:html_url).filled(:string)
      end

      rule(:html_url) do
        unless URI.parse(value) && URI.parse(value).host == 'github.com' && URL_REGEX.match?(value)
          key.failure('is an invalid url. We cannot load your document from here.')
        end
      rescue URI::InvalidURIError
        key.failure('is an invalid url. We cannot load your document from here.')
      end
    end
  end
end

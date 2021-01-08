# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative '../responses/openstruct_with_links'
require_relative 'document_representer'

module MindMap
  module Representer
    # Represents a list of documents
    class DocumentsList < Roar::Decorator
      include Roar::JSON

      collection :documents, extend: Representer::Document,
                             class: Response::OpenStructWithLinks
    end
  end
end

# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'inbox_representer'

module MindMap
  module Representer
    # Represents list of inboxs for API output
    class InboxsList < Roar::Decorator
      include Roar::JSON

      collection :inbox, extend: Representer::Inbox, class: Response::OpenStructWithLinks
    end
  end
end

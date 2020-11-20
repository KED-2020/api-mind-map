# frozen_string_literal: true

module MindMap
  module Mapper
    # Inbox for managing inbox services.
    class Inbox
      def initialize(inbox)
        @inbox = inbox
      end

      def build_entity
      end

      def suggestions
        # This will need to be smarter later.
        @inbox.suggestions
      end
    end
  end
end

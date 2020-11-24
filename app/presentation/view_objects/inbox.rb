# frozen_string_literal: true

module Views
  # View for a single inbox
  class Inbox
    def initialize(inbox)
      @inbox = inbox
    end

    def entity
      @inbox
    end

    def inbox_url
      @inbox.url
    end

    def inbox_name
      @inbox.name
    end

  end
end

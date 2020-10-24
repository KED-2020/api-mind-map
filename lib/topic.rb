# frozen_string_literal: true

module MindMap
  # Model for a Topic
  class Topic
    attr_reader :name

    def initialize(name, source = nil)
      @name = name
      @source = source
    end

    def self.topics_to_query_string(topics)
      return '' if topics.length.zero?

      topics.reduce('') do |query, topic|
        "#{query} topic:#{topic}"
      end
    end
  end
end

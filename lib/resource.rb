# frozen_string_literal: true

module MindMap
  # Model for a resource
  class Resource
    def initialize(resource_data, source)
      @resource = resource_data
      @source = source
    end

    def name
      @resource['name']
    end

    def description
      @resource['description']
    end

    def url
      @resource['github_url']
    end

    def homepage
      @resource['homepage']
    end

    def language
      @resource['language']
    end

    def topics
      return [] if @resource['topics'].length.zero?

      @resource['topics'].map { |topic| MindMap::Topic.new(topic) }
    end
  end
end

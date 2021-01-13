# frozen_string_literal: true

require_relative 'progress_publisher'

module Suggestions
  # Reports job progress to client
  class JobReporter
    attr_accessor :inbox, :subscriptions

    def initialize(request_json, config)
      suggestions_request = MindMap::Representer::SuggestionsRequest.new(OpenStruct.new)
                                                                    .from_json(request_json)

      @project = suggestions_request.inbox
      @subscriptions = inbox.subscriptions
      @publisher = ProgressPublisher.new(config, clone_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end

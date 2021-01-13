# frozen_string_literal: true

require_relative '../app/domain/init'
require_relative '../app/infrastructure/init'
require_relative '../app/application/requests/init'
require_relative '../app/presentation/representers/init'
require_relative 'suggestions_monitor'
require_relative 'job_reporter'

require 'econfig'
require 'shoryuken'

module MindMap
  # Shoryuken worker class to load suggestions
  class Worker
    extend Econfig::Shortcut
    Econfig.env = ENV['RACK_ENV'] || 'development'
    Econfig.root = File.expand_path('..', File.dirname(__FILE__))

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
    shoryuken_options queue: config.SUGGESTIONS_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = SuggestionsReporter.new(request, Worker.config)
      suggestions = []

      job.report(Suggestions::SuggestionMonitor.starting_percent)
      job.subscriptions.each do |subscription|
        subscription.keywords.each do |keyword|
          result = Mapper::Inbox.new(MindMap::App.config.GITHUB_TOKEN).get_suggestions(keyword)
          suggestions.push(result)
        end
      end

      MindMap::Repository::For.klass(Entity).add_suggestions(job.inbox, suggestions)

      # Keep sending finished status to any late coming subscribers
      job.report_each_second(5) { Suggestions::SuggestionMonitor.finished_percent }
    rescue StandardError
      # worker should crash early & often - only catch errors we expect!
      puts 'Something unexpected happen. Please load the suggestions again.'
    end
  end
end

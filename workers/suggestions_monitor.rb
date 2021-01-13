# frozen_string_literal: true

module Suggestions
  # Infrastructure to load subscriptions while yielding progress
  module SuggestionMonitor
    SUBSCRIPTIONS_PROCESS = {
      'STARTED'   => 15,
      'Loading Subscriptions'   => 30,
      'remote'    => 70,
      'Receiving' => 85,
      'Resolving' => 95,
      'Checking'  => 100,
      'FINISHED'  => 100
    }.freeze

    def self.starting_percent
      SUBSCRIPTIONS_PROCESS['STARTED'].to_s
    end

    def self.finished_percent
      SUBSCRIPTIONS_PROCESS['FINISHED'].to_s
    end

    def self.progress(line)
      SUBSCRIPTIONS_PROCESS[first_word_of(line)].to_s
    end

    def self.percent(stage)
      SUBSCRIPTIONS_PROCESS[stage].to_s
    end

    def self.first_word_of(line)
      line.match(/^[A-Za-z]+/).to_s
    end
  end
end

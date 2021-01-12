# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative '../responses/openstruct_with_links'
require_relative 'subscription_representer'

module MindMap
  module Representer
    # Represents a list of documents
    class SubscriptionsList < Roar::Decorator
      include Roar::JSON

      collection :subscriptions, extend: Representer::Subscription,
                                 class: Response::OpenStructWithLinks
    end
  end
end

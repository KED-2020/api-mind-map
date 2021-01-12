# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Converts an inbox from an inbox suggestion to a inbox document
    class SaveInboxSuggestion
      include Dry::Transaction

      step :find_inbox
      step :find_inbox_suggestion
      step :upgrade_suggestion_to_document
      step :delete_suggestion

      private

      INBOX_NOT_FOUND_MSG = 'Could not find inbox with the given id.'
      SUGGESTION_NOT_FOUND_MSG = 'Could not find suggestion with the given id.'
      DB_ERROR_MSG = 'Could not access database.'

      def find_inbox(input)
        if (inbox = Repository::For.klass(Entity::Inbox).find_by_url(input[:inbox_url]))
          Success(input.merge!(inbox: inbox))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: INBOX_NOT_FOUND_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def find_inbox_suggestion(input)
        input[:suggestion] = Repository::For.klass(Entity::Suggestion)
                                            .find_suggestion(input[:inbox], input[:suggestion_id])

        if input[:suggestion].nil?
          Failure(Response::ApiResult.new(status: :not_found, message: SUGGESTION_NOT_FOUND_MSG))
        else
          Success(input)
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def upgrade_suggestion_to_document(input)
        html_url = input[:suggestion].html_url
        document = Repository::For.klass(Entity::Document).find_html_url(html_url)

        Repository::For.klass(Entity::Inbox).add_document(input[:inbox_url], document)

        Success(input.merge(document: document))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end

      def delete_suggestion(input)
        Repository::For.klass(Entity::Inbox)
                       .remove_suggestion(input[:inbox_url], input[:suggestion_id])

        Success(Response::ApiResult.new(status: :created, message: input[:document]))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

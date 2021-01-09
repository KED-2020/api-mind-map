# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Converts an inbox from an inbox suggestion to a inbox document
    class SaveInboxSuggestion
      include Dry::Transaction

      step :validate_params
      step :verify_inbox_exists
      step :find_inbox_suggestion
      step :upgrade_suggestion_to_document

      private

      INBOX_NOT_FOUND_MSG = 'Could not find inbox with the given id.'
      SUGGESTION_NOT_FOUND_MSG = 'Could not find suggestion with the given id.'
      DB_ERROR_MSG = 'Could not access database.'

      def validate_params(input)
        Success(input)
      end

      def verify_inbox_exists(input)
        if Repository::For.klass(Entity::Inbox).exists(input[:inbox_url])
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: INBOX_NOT_FOUND_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: DB_ERROR_MSG))
      end

      def find_inbox_suggestion(input)
        input[:suggestion] = Repository::For.klass(Entity::Suggestion)
                                            .find_inbox_suggestion(input[:suggestion_id])

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

        Repository::For.klass(Entity::Inbox).add_documents(input[:inbox_url], [document])

        Success(Response::ApiResult.new(status: :created, message: document))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR_MSG))
      end
    end
  end
end

# frozen_string_literal: true

require 'dry/transaction'

module MindMap
  module Service
    # Adds a document to the database
    class AddDocument
      include Dry::Transaction

      step :parse_url
      step :find_document
      step :store_document

      private

      INVALID_PARAMS_MSG = 'Invalid link to GitHub document provided.'
      GH_NOT_FOUND_MSG = 'Could not find that project on GitHub.'
      DB_ERROR_MSG = 'Having trouble accessing the database.'

      def parse_url(input)
        throw INVALID_PARAMS_MSG unless input.success?

        document_owner, document = input[:html_url].split('/')[-2..-1]
        Success(document_path: "#{document_owner}/#{document}", html_url: input[:html_url])
      rescue StandardError
        Failure(Response::ApiResult.new(status: :bad_request, message: e.to_s))
      end

      def find_document(input)
        if (document = document_from_database(input))
          input[:local_document] = document
        else
          input[:remote_document] = document_from_github(input)
        end

        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_document(input)
        document = if input[:remote_document]
                     MindMap::Repository::For.klass(Entity::Document).create(input[:remote_document])
                   else
                     input[:local_document]
                   end

        Success(Response::ApiResult.new(status: :created, message: document))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERROR))
      end

      def document_from_database(input)
        MindMap::Repository::For.klass(Entity::Document).find_html_url(input[:html_url])
      end

      def document_from_github(input)
        Github::DocumentMapper.new(MindMap::App.config.GITHUB_TOKEN).find(input[:document_path])
      rescue StandardError
        raise GITHUB_NOT_FOUND
      end
    end
  end
end

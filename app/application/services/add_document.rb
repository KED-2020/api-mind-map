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

      def parse_url(input)
        if input.success?
          document_owner, document = input[:html_url].split('/')[-2..-1]
          Success(document_path: "#{document_owner}/#{document}", html_url: input[:html_url])
        else
          Failure('Invalid link to GitHub document provided')
        end
      rescue StandardError
        Failure('Invalid link to GitHub document provided')
      end

      def find_document(input)
        if (document = document_from_database(input))
          input[:local_document] = document
        else
          input[:remote_document] = document_from_github(input)
        end

        Success(input)
      rescue StandardError => e
        Failure(e.to_s)
      end

      def store_document(input)
        document = if input[:remote_document]
                     MindMap::Repository::For.klass(Entity::Document).create(input[:remote_document])
                   else
                     input[:local_document]
                   end

        Success(document)
      rescue StandardError
        Failure('Having trouble accessing the database')
      end

      def document_from_database(input)
        MindMap::Repository::For.klass(Entity::Document).find_html_url(input[:html_url])
      end

      def document_from_github(input)
        Github::DocumentMapper.new(MindMap::App.config.GITHUB_TOKEN).find(input[:document_path])
      rescue StandardError
        raise 'Could not find that project on Github'
      end
    end
  end
end

# frozen_string_literal: true

require 'roda'
require 'delegate'

module MindMap
  # Environment-specific configuration
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "MindMap API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        # Inbox
        routing.on 'inboxes' do
          # GET /inboxes/{inbox_id}
          routing.on String do |inbox_id|
            routing.get do
              inbox_find = Request::EncodedInboxId.new(inbox_id)

              result = Service::GetInbox.new.call(inbox_id: inbox_find)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Inbox.new(
                result.value!.message
              ).to_json
            end
          end
        end

        # Favorites
        routing.on 'favorites' do
          routing.on 'documents' do
            # POST /favorites/documents
            routing.post do
              html_url = Request::AddDocument.new(routing.params)

              result = Service::AddDocument.new.call(html_url: html_url)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              # Return the document the user just created
              Representer::Document.new(
                result.value!.message
              ).to_json
            end

            # GET /favorites/documents/{document_id}
            routing.on String do |document_id|
              routing.get do
                result = MindMap::Service::GetDocument.new.call(document_id: document_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code

                # Return the document the user requested
                Representer::Document.new(
                  result.value!.message
                ).to_json
              end
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end

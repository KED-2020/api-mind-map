# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'delegate'

module MindMap
  # Environment-specific configuration
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :partials

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      routing.assets # Load CSS

      # GET /
      routing.root do
        view 'home'
      end

      # GET /document_nil
      routing.on 'document_nil' do
        view 'document_nil'
      end

      # Inbox
      routing.on 'inbox' do
        # GET /inbox/guest-inbox
        routing.on 'guest-inbox' do
          routing.get do
            # Get guest suggestions from cookie/session
            session[:suggestions] ||= []

            session[:suggestions].insert(0, "suggestion1").uniq!
            session[:suggestions].insert(0, "suggestion2").uniq!
            # session[:suggestions].delete("suggestion1")
            # session[:suggestions].delete("suggestion2")
            # puts "guest_suggestions = #{session[:suggestions]}"

            # Reserve a specific id for 'guest-inbox' (# nice pattern?)
            guest_inbox_id = 'guest-inbox'

            # Find the inbox specified by the url.
            inbox = Repository::Inbox::For.klass(Entity::Inbox).find_url(guest_inbox_id)

            unless inbox
              flash[:error] = "Guest Inbox doesn't exist"
              routing.redirect '/'
            end

            # Currently, no suggestions for an guest inbox.
            suggestions = []

            # Show the user their inbox
            view 'inbox', locals: { inbox: Views::Inbox.new(inbox, suggestions) }
          end
        end

        # GET /inbox/{inbox_id}
        routing.on String do |inbox_id|
          routing.get do
            inbox_find = MindMap::Forms::FindInbox.new.call(inbox_id: inbox_id)

            result = Service::GetInbox.new.call(inbox_id: inbox_id)

            if result.failure?
              flash[:error] = result.failure
              routing.redirect '/'
            end

            inbox = result.value!
            # Show the user their inbox
            view 'inbox', locals: { inbox: Views::Inbox.new(inbox[:inbox], inbox[:suggestions]) }
          end
        end

        # POST /inbox/
        routing.post do
          inbox_id = routing.params['inbox_id']

          # Redirect to the get request
          routing.redirect "/inbox/#{inbox_id}"
        end

        # GET /inbox
        routing.get do
          # Reserve a specific id for 'guest-inbox' (# nice pattern?)
          new_inbox_id = ''

          # Find the inbox specified by the url.
          result = Service::GetInbox.new.call(inbox_id: new_inbox_id)

          if result.failure?
            flash[:error] = result.failure
            routing.redirect '/'
          end

          inbox = result.value!
          # Show the user their inbox
          view 'inbox', locals: { inbox: Views::Inbox.new(inbox[:inbox], inbox[:suggestions]) }
        end
      end

      # Favorites
      routing.on 'favorites' do
        # GET /favorites
        routing.get do
          view 'favorites'
        end

        routing.on 'documents' do
          # POST /favorites/documents
          routing.post do
            html_url = MindMap::Forms::AddDocument.new.call(routing.params)

            result = Service::AddDocument.new.call(html_url)

            if result?.failure
              flash[:error] = result.failure
              routing.redirect '/favorites'
            end

            # Show the user their favorites
            routing.redirect '/favorites'
          end

          # GET /favorites/documents/{document_id}
          routing.on String do |document_id|
            routing.get do
              document = Repository::For.klass(Entity::Document).find_id(document_id)

              if document.nil?
                flash[:error] = 'Document not found'
                routing.redirect '/document_nil'
              end

              view 'document', locals: { document: document }
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end

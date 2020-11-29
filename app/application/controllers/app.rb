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

      # GET /resource_nil
      routing.on 'resource_nil' do
        view 'resource_nil'
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

      # Resource
      routing.on 'resource' do
        routing.is do
          # POST /resource/
          routing.post do
            search_term = routing.params['search']
            tags_term = routing.params['tags']

            routing.halt 400 unless search_term.length.positive?

            tags = tags_term&.length&.positive? ? tags_term.split(',') : []

            # Get the resource from Github
            resource = Github::ResourceMapper
                       .new(MindMap::App.config.GITHUB_TOKEN)
                       .search(search_term, tags)
            routing.redirect '/resource_nil' unless resource
            # Add the repo to database
            saved_resource = Repository::For.entity(resource).find_or_create(resource)

            # Redirect viewer to resource details
            routing.redirect "/resource?resource_origin_id=#{saved_resource.origin_id}"
          end

          # GET /resource?resource_origin_id={resource_origin_id}
          routing.get do
            resource_origin_id = routing.params['resource_origin_id']

            resource = Repository::For.klass(Entity::Resource).find_origin_id(resource_origin_id)

            view 'resource', locals: { resource: resource }
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end

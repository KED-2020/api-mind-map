# frozen_string_literal: true

require 'roda'
require 'slim'

module MindMap
  # Web app
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt

    route do |routing|
      routing.assets # Load CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'resource' do
        routing.is do
          # GET /resource/
          routing.post do
            gh_url = routing.params['github_url'].downcase

            routing.halt 400 unless (gh_url.include? 'github.com') &&
                                    (gh_url.split('/').count >= 3)

            owner, project = gh_url.split('/')[-2..-1]

            routing.redirect "resource/#{owner}/#{project}"
          end
        end
      end
    end
  end
end

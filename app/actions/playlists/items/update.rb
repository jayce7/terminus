# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      module Items
        # The update action.
        class Update < Action
          include Deps[
            repository: "repositories.playlist_item",
            show_view: "views.playlists.items.show"
          ]

          contract Contracts::PlaylistItems::Update

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            save parameters, response
          end

          private

          def save parameters, response
            item = repository.find_by playlist_id: parameters[:playlist_id], id: parameters[:id]
            id = item.id
            repository.update id, **parameters[:playlist_item]

            response.render show_view, item: repository.find(id), layout: false
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Terminus
  module Contracts
    module PlaylistItems
      # The contract for playlist item creates.
      class Create < Contract
        params do
          required(:playlist_id).filled :integer
          required(:playlist_item).filled Schemas::PlaylistItems::Upsert
        end
      end
    end
  end
end

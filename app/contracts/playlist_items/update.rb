# frozen_string_literal: true

module Terminus
  module Contracts
    module PlaylistItems
      # The contract for playlist item updates.
      class Update < Contract
        params do
          required(:id).filled :integer
          required(:playlist_id).filled :integer
          required(:playlist_item).filled Schemas::PlaylistItems::Upsert
        end
      end
    end
  end
end

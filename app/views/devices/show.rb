# frozen_string_literal: true

module Terminus
  module Views
    module Devices
      # The show view.
      class Show < View
        decorate :device
        expose :playlists
      end
    end
  end
end

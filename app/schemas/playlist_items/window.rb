# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module PlaylistItems
      # Defines playlist item display window schema.
      Window = Dry::Schema.Params do
        required(:days).filled(:array).each Types::Day
        required(:start).filled Types::ClockTime
        required(:end).filled Types::ClockTime
      end
    end
  end
end

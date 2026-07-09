# frozen_string_literal: true

require "date"
require "hanami/view"

module Terminus
  module Views
    module Parts
      # The playlist item presenter.
      class Item < Hanami::View::Part
        # The first day (a Sunday) of an arbitrary week used to compute weekly coverage.
        WEEK_START = Date.new 2024, 1, 7

        def coverage
          Date::DAYNAMES.map.with_index { |name, day| [name[0], hours(day)] }
        end

        private

        def hours(day) = Array.new(24) { |hour| covered? day, hour }

        # Samples the middle of the hour so wrapped and partial windows register.
        def covered? day, hour
          moment = WEEK_START.next_day(day).to_time + (hour * 3600) + 1800
          value.scheduled? moment
        end
      end
    end
  end
end

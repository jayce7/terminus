# frozen_string_literal: true

require "date"

module Terminus
  module Structs
    # The playlist item struct.
    class PlaylistItem < DB::Struct
      def cloneable_attributes
        {
          screen_id:,
          position:,
          repeat_interval:,
          repeat_type:,
          repeat_days:,
          last_day_of_month:,
          start_at:,
          stop_at:,
          hidden_at:,
          windows:
        }
      end

      def scheduled? at = Time.now
        day, minutes = moment at

        windows.any? { |window| window["days"].include?(day) && covered?(window, minutes) }
      end

      private

      # :reek:UtilityFunction
      def moment at
        [Date::DAYNAMES.fetch(at.wday).downcase, (at.hour * 60) + at.min]
      end

      # :reek:FeatureEnvy
      def covered? window, minutes
        start = minutes_for window["start"]
        stop = minutes_for window["end"]
        checks = [minutes >= start, minutes < stop]

        stop <= start ? checks.any? : checks.all?
      end

      # :reek:UtilityFunction
      def minutes_for clock
        hours, minutes = clock.split(":").map(&:to_i)
        (hours * 60) + minutes
      end
    end
  end
end

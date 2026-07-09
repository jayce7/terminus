# frozen_string_literal: true

Factory.define :playlist_item, relation: :playlist_item do |factory|
  factory.association :playlist
  factory.association :screen
  factory.sequence(:position) { it }
  factory.repeat_type "none"

  factory.windows [
    {
      "days" => %w[sunday monday tuesday wednesday thursday friday saturday],
      "start" => "00:00",
      "end" => "00:00"
    }
  ]
end

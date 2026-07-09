# frozen_string_literal: true

ROM::SQL.migration do
  change do
    default = '[{"days": ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", ' \
              '"saturday"], "start": "00:00", "end": "00:00"}]'

    add_column :playlist_item, :windows, :jsonb, null: false, default:
  end
end

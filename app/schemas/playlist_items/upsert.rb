# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module PlaylistItems
      # Defines playlist item upsert schema.
      Upsert = Dry::Schema.Params do
        required(:screen_id).filled :integer
        optional(:windows).array Window

        after(:value_coercer, &Coercers::JSONToArray.curry[:windows])
      end
    end
  end
end

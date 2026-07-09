# auto_register: false
# frozen_string_literal: true

require "json"
require "refinements/hash"

module Terminus
  module Schemas
    # Coerces a key's JSON value into an array.
    module Coercers
      using Refinements::Hash

      JSONToArray = lambda do |key, result|
        attributes = Hash result.to_h

        attributes.transform_value! key do |value|
          value.is_a?(::String) ? JSON(value, symbolize_names: true) : value
        end
      rescue JSON::ParserError
        attributes
      end
    end
  end
end

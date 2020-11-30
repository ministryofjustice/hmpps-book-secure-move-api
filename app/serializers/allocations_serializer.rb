# frozen_string_literal: true

class AllocationsSerializer < AllocationSerializer
  meta do |object, params|
    {
      moves: params.dig(:totals, object.id),
    }
  end

  INCLUDED_FIELDS = {
    allocations: attributes_to_serialize.keys + %i[from_location to_location],
    locations: LocationSerializer.attributes_to_serialize.keys,
  }.freeze

  SUPPORTED_RELATIONSHIPS = %w[from_location to_location].freeze
end

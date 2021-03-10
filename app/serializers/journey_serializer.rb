# frozen_string_literal: true

class JourneySerializer < JourneysSerializer
  set_type :journeys

  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    from_location
    from_location.suppliers
    to_location
    to_location.suppliers
  ].freeze
end

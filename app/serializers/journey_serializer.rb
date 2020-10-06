# frozen_string_literal: true

class JourneySerializer
  include JSONAPI::Serializer

  set_type :journeys

  attributes :state, :billable, :vehicle
  attribute :timestamp, &:client_timestamp

  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    from_location
    from_location.suppliers
    to_location
    to_location.suppliers
  ].freeze
end

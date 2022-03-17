# frozen_string_literal: true

class JourneysSerializer
  include JSONAPI::Serializer

  set_type :journeys

  attributes :state, :billable, :vehicle, :date, :number
  attribute :timestamp, &:client_timestamp

  has_one :from_location, serializer: LocationsSerializer
  has_one :to_location, serializer: LocationsSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    from_location
    to_location
  ].freeze
end

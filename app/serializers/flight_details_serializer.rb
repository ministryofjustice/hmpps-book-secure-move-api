# frozen_string_literal: true

class FlightDetailsSerializer
  include JSONAPI::Serializer

  set_type :flight_details

  attributes :flight_number,
             :flight_time

  belongs_to :move, serializer: MoveSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    move
  ].freeze
end

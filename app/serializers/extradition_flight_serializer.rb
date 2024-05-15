# frozen_string_literal: true

class ExtraditionFlightSerializer
  include JSONAPI::Serializer

  set_type :extradition_flight

  attributes :flight_number,
             :flight_time

  belongs_to :move, serializer: MoveSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    move
  ].freeze
end

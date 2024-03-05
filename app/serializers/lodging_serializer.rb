# frozen_string_literal: true

class LodgingSerializer
  include JSONAPI::Serializer

  set_type :lodgings

  attributes :start_date,
             :end_date,
             :status

  belongs_to :move
  belongs_to :location, serializer: LocationSerializer

  SUPPORTED_RELATIONSHIPS = %w[
    location
  ].freeze
end

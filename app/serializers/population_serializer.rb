# frozen_string_literal: true

class PopulationSerializer
  include JSONAPI::Serializer

  set_type :populations

  attributes :date,
             :operational_capacity,
             :usable_capacity,
             :unlock,
             :bedwatch,
             :overnights_in,
             :overnights_out,
             :out_of_area_courts,
             :discharges,
             :free_spaces,
             :updated_by,
             :created_at,
             :updated_at

  belongs_to :location
  has_many :moves_from, serializer: V2::MoveSerializer, &:moves_from
  has_many :moves_to, serializer: V2::MoveSerializer, &:moves_to

  SUPPORTED_RELATIONSHIPS = %w[
    location
    moves_from
    moves_to
  ].freeze
end

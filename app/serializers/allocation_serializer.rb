# frozen_string_literal: true

class AllocationSerializer
  include JSONAPI::Serializer

  set_type :allocations

  attributes :moves_count,
             :date,
             :estate,
             :estate_comment,
             :prisoner_category,
             :sentence_length,
             :sentence_length_comment,
             :complex_cases,
             :complete_in_full,
             :requested_by,
             :other_criteria,
             :status,
             :cancellation_reason,
             :cancellation_reason_comment,
             :created_at,
             :updated_at

  has_one :from_location, serializer: LocationSerializer
  has_one :to_location, serializer: LocationSerializer
  has_many :moves, serializer: V2::MoveSerializer

  meta do |object|
    {
      moves: object.move_totals,
    }
  end

  SUPPORTED_RELATIONSHIPS = %w[
    from_location
    to_location
    moves.person
    moves.person.gender
    moves.person.ethnicity
    moves.profile.person.ethnicity
    moves.profile.person.gender
  ].freeze
end

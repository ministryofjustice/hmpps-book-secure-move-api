# frozen_string_literal: true

class AllocationSerializer < ActiveModel::Serializer
  attributes :moves_count,
             :date,
             :prisoner_category,
             :sentence_length,
             :complex_cases,
             :complete_in_full,
             :other_criteria,
             :status,
             :cancellation_reason,
             :cancellation_reason_comment,
             :created_at,
             :updated_at

  has_one :from_location
  has_one :to_location
  has_many :moves

  INCLUDED_ATTRIBUTES = {
    from_location: [],
    to_location: [],
    moves: %i[person],
  }.freeze
end

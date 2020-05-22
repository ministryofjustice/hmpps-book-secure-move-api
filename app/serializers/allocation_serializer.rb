# frozen_string_literal: true

class AllocationSerializer < ActiveModel::Serializer
  attributes :moves_count,
             :date,
             :prisoner_category,
             :sentence_length,
             :complex_cases,
             :complete_in_full,
             :requested_by,
             :other_criteria,
             :status,
             :cancellation_reason,
             :cancellation_reason_comment,
             :created_at,
             :updated_at

  has_one :from_location
  has_one :to_location
  has_many :moves

  INCLUDED_ATTRIBUTES = %w[from_location to_location moves.person].freeze
end

# frozen_string_literal: true

class Move < ApplicationRecord
  MOVE_STATUS_REQUESTED = 'requested'
  MOVE_STATUS_COMPLETED = 'completed'
  MOVE_STATUS_CANCELLED = 'cancelled'

  NOMIS_STATUS_TYPES = {
    'SCH' => MOVE_STATUS_REQUESTED,
    'EXP' => MOVE_STATUS_REQUESTED,
    'COMP' => MOVE_STATUS_COMPLETED
  }.freeze

  enum status: {
    requested: MOVE_STATUS_REQUESTED,
    completed: MOVE_STATUS_COMPLETED,
    cancelled: MOVE_STATUS_CANCELLED
  }

  enum move_type: {
    court_appearance: 'court_appearance',
    prison_recall: 'prison_recall',
    prison_transfer: 'prison_transfer'
  }

  enum cancellation_reason: {
    made_in_error: 'made_in_error',
    supplier_declined_to_move: 'supplier_declined_to_move',
    other: 'other'
  }

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location', optional: true
  belongs_to :person

  validates :from_location, presence: true
  validates(
    :to_location,
    presence: true,
    unless: ->(move) { move.move_type == 'prison_recall' }
  )
  validates :date, presence: true
  validates :move_type, inclusion: { in: move_types }
  validates :person, presence: true
  validates :reference, presence: true
  validates :status, inclusion: { in: statuses }
  validates :nomis_event_id, uniqueness: true, allow_nil: true

  before_validation :set_reference
  before_validation :set_move_type

  def from_nomis?
    !nomis_event_id.nil?
  end

  private

  def set_reference
    self.reference ||= Moves::ReferenceGenerator.new.call
  end

  def set_move_type
    return if move_type.present?

    self.move_type =
      if to_location.nil?
        'prison_recall'
      elsif to_location_is_court?
        'court_appearance'
      else
        'prison_transfer'
      end
  end

  def to_location_is_court?
    to_location&.location_type == 'court'
  end
end

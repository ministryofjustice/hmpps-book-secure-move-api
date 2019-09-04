# frozen_string_literal: true

class Move < ApplicationRecord
  enum status: {
    requested: 'requested',
    cancelled: 'cancelled'
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

  before_validation :set_reference
  before_validation :set_move_type

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

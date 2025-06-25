# frozen_string_literal: true

class Lodging < ApplicationRecord
  include StateMachineable

  CANCELLATION_REASONS = [
    CANCELLATION_REASON_MADE_IN_ERROR = 'made_in_error',
    CANCELLATION_REASON_SUPPLIER_DECLINED_TO_MOVE = 'supplier_declined_to_move',
    CANCELLATION_REASON_CANCELLED_BY_PMU = 'cancelled_by_pmu',
    CANCELLATION_REASON_OTHER = 'other',
  ].freeze

  validates :move, presence: true
  validates :location, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validates_each :start_date, :end_date do |record, attr, value|
    Date.iso8601(value)
  rescue ArgumentError
    record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
  end

  validate :end_date_after_start_date

  validate :validate_lodging_uniqueness, unless: -> { cancelled? }

  has_many :generic_events, as: :eventable, dependent: :destroy

  belongs_to :move, touch: true
  belongs_to :location

  has_state_machine LodgingStateMachine, on: :status

  delegate :start,
           :complete,
           :cancel,
           :started?,
           :completed?,
           :cancelled?,
           to: :state_machine

  scope :default_order, -> { order(start_date: :asc) }
  scope :not_cancelled, -> { where.not(status: 'cancelled') }

private

  def validate_lodging_uniqueness
    errors.add(:start_date, :taken) if existing_lodgings.any?
  end

  def existing_lodgings
    Lodging
      .not_cancelled
      .where(
        move_id:,
        start_date:,
        end_date:,
      )
      .where.not(id:) # When updating an existing lodging, don't consider self a duplicate
  end

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if Date.parse(end_date) <= Date.parse(start_date)
      errors.add(:end_date, 'must be after start_date')
    end
  end
end

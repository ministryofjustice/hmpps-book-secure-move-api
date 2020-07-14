# frozen_string_literal: true

class Allocation < VersionedModel
  include StateMachineable

  ALLOCATION_STATUS_UNFILLED = 'unfilled'
  ALLOCATION_STATUS_FILLED = 'filled'
  ALLOCATION_STATUS_CANCELLED = 'cancelled'

  enum prisoner_category: {
    b: 'B',
    c: 'C',
    d: 'D',
    open: 'Open',
    closed: 'Closed',
  }

  enum sentence_length: {
    short: '16_or_less',
    long: 'more_than_16',
    other: 'other',
  }

  enum estate: {
    adult_female: 'Adult Female',
    adult_male: 'Adult Male',
    juvenile_female: 'Juvenile Female',
    juvenile_male: 'Juvenile Male',
    young_offender_female: 'Young Offender Female',
    young_offender_male: 'Young Offender Male',
    other_estate: 'Other',
  }

  enum states: {
    unfilled: ALLOCATION_STATUS_UNFILLED,
    filled: ALLOCATION_STATUS_FILLED,
    cancelled: ALLOCATION_STATUS_CANCELLED,
  }

  CANCELLATION_REASONS = [
    CANCELLATION_REASON_MADE_IN_ERROR = 'made_in_error',
    CANCELLATION_REASON_SUPPLIER_DECLINED_TO_MOVE = 'supplier_declined_to_move',
    CANCELLATION_REASON_LACK_OF_SPACE = 'lack_of_space_at_receiving_establishment',
    CANCELLATION_REASON_FAILED_TO_FILL_ALLOCATION = 'sending_establishment_failed_to_fill_allocation',
    CANCELLATION_REASON_OTHER = 'other',
  ].freeze

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  has_many :moves, inverse_of: :allocation, dependent: :destroy, autosave: true
  has_many :events, as: :eventable, dependent: :destroy

  validates :status, presence: true, inclusion: { in: states }

  validates :from_location, presence: true
  validates :to_location, presence: true

  validates :prisoner_category, inclusion: { in: prisoner_categories }, allow_nil: true
  validates :sentence_length, inclusion: { in: sentence_lengths }, allow_nil: true
  validates :estate, inclusion: { in: estates }, allow_nil: true

  validates :moves_count, presence: true, numericality: { only_integer: true, greater_than: 0 }, on: :create
  validates :date, presence: true

  validates :cancellation_reason, inclusion: { in: CANCELLATION_REASONS }, if: :cancelled?
  validates :cancellation_reason, absence: true, unless: :cancelled?

  attribute :complex_cases, Types::Jsonb.new(Allocation::ComplexCaseAnswers)

  has_state_machine AllocationStateMachine, on: :status

  delegate :fill, :unfill, :filled?, :unfilled?, :cancelled?, to: :state_machine

  def cancel(reason: CANCELLATION_REASON_OTHER, comment: 'Allocation was cancelled')
    assign_attributes(
      cancellation_reason: reason,
      cancellation_reason_comment: comment,
      moves_count: 0,
    )

    state_machine.cancel

    save!
  end

  def refresh_status_and_moves_count!
    current_moves = moves.not_cancelled

    current_moves.unfilled? ? unfill : fill
    self.moves_count = current_moves.count

    save!
  end
end

# frozen_string_literal: true

class Allocation < VersionedModel
  ALLOCATION_STATUS_UNFILLED = 'unfilled'
  ALLOCATION_STATUS_FILLED = 'filled'
  ALLOCATION_STATUS_CANCELLED = 'cancelled'

  enum prisoner_category: {
    b: 'B',
    c: 'C',
    d: 'D',
  }

  enum sentence_length: {
    short: '16_or_less',
    long: 'more_than_16',
  }

  # TODO: implement statemachine, for now just allow an allocation to be cancelled
  enum status: {
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

  validates :from_location, presence: true
  validates :to_location, presence: true

  validates :prisoner_category, inclusion: { in: prisoner_categories }, allow_nil: true
  validates :sentence_length, inclusion: { in: sentence_lengths }, allow_nil: true

  validates :moves_count, presence: true, numericality: { only_integer: true, greater_than: 0 }, on: :create
  validates :date, presence: true

  validates :cancellation_reason, inclusion: { in: CANCELLATION_REASONS }, if: :cancelled?
  validates :cancellation_reason, absence: true, unless: :cancelled?

  attribute :complex_cases, Types::JSONB.new(Allocation::ComplexCaseAnswers)

  after_initialize :initialize_state
  delegate :fill, :unfill, to: :state_machine

  def cancel
    comment = 'Allocation was cancelled'

    assign_attributes(
      cancellation_reason: CANCELLATION_REASON_OTHER,
      cancellation_reason_comment: comment,
      moves: moves.each { |move| move.cancel(comment: comment) },
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

private

  def state_machine
    @state_machine ||= AllocationStateMachine.new(self)
  end

  def initialize_state
    if status.present?
      state_machine.restore!(status.to_sym)
    else
      self.status = state_machine.current
    end
  end
end

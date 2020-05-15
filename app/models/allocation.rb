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
    MADE_IN_ERROR = 'made_in_error',
    SUPPLIER_DECLINED_TO_MOVE = 'supplier_declined_to_move',
    LACK_OF_SPACE = 'lack_of_space_at_receiving_establishment',
    FAILED_TO_FILL_ALLOCATION = 'sending_establishment_failed_to_fill_allocation',
    OTHER = 'other',
  ].freeze

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  has_many :moves, inverse_of: :allocation, dependent: :destroy, autosave: true
  has_many :events, as: :eventable, dependent: :destroy

  validates :from_location, presence: true
  validates :to_location, presence: true

  validates :prisoner_category, inclusion: { in: prisoner_categories }, allow_nil: true
  validates :sentence_length, inclusion: { in: sentence_lengths }, allow_nil: true

  validates :moves_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  # TODO: re-enable once cancellation reason is implemented in FE
  # validates :cancellation_reason, inclusion: { in: CANCELLATION_REASONS }, if: :cancelled?
  # validates :cancellation_reason, absence: true, unless: :cancelled?

  attribute :complex_cases, Types::JSONB.new(Allocation::ComplexCaseAnswers)

  def cancel
    self.status = ALLOCATION_STATUS_CANCELLED
    self.moves.each { |move| move.assign_attributes(status: Move::MOVE_STATUS_CANCELLED) }

    save!
  end
end

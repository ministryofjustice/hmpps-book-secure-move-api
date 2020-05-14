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

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  has_many :moves, inverse_of: :allocation, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy

  validates :from_location, presence: true
  validates :to_location, presence: true

  validates :prisoner_category, inclusion: { in: prisoner_categories }, allow_nil: true
  validates :sentence_length, inclusion: { in: sentence_lengths }, allow_nil: true

  validates :moves_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  attribute :complex_cases, Types::JSONB.new(Allocation::ComplexCaseAnswers)
end

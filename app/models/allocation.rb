# frozen_string_literal: true

class Allocation < VersionedModel
  enum prisoner_category: {
    b: 'B',
    c: 'C',
    d: 'D',
  }

  enum sentence_length: {
    short: '16_or_less',
    long: 'more_than_16',
  }

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'
  has_many :moves, inverse_of: :allocation, dependent: :destroy

  validates :from_location, presence: true
  validates :to_location, presence: true

  validates :prisoner_category, inclusion: { in: prisoner_categories }, allow_nil: true
  validates :sentence_length, inclusion: { in: sentence_lengths }, allow_nil: true

  validates :moves_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :date, presence: true

  attribute :complex_cases, Types::JSONB.new(Allocation::ComplexCaseAnswers)
end

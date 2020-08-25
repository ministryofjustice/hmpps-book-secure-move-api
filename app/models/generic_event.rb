class GenericEvent < ApplicationRecord
  CREATED_BY_OPTIONS = %w[serco geoamey unknown].freeze

  belongs_to :eventable, polymorphic: true, touch: true

  validates :eventable,   presence: true
  validates :type,        presence: true
  validates :occurred_at, presence: true
  validates :details,     presence: true
  validates :created_by,  presence: true, inclusion: { in: CREATED_BY_OPTIONS }

  # This scope is used to determine the apply order of events as they were determined to have occurred.
  # The order is important as far as the eventable state machine sequencing, the correctness
  # of any attributes of the eventable and for reporting purposes.
  scope :applied_order, -> { order(occurred_at: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer
end

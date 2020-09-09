class GenericEvent < ApplicationRecord
  CREATED_BY_OPTIONS = %w[serco geoamey unknown].freeze
  FEED_ATTRIBUTES = %w[
    id
    type
    actioned_by
    notes
    created_at
    updated_at
    occurred_at
    recorded_at
    eventable_id
    eventable_type
    details
  ].freeze
  STI_CLASSES = %w[
    MoveCancel
    JourneyCancel
    JourneyComplete
    JourneyLockout
    JourneyLodging
    JourneyReject
    JourneyStart
    JourneyUncancel
    JourneyUncomplete
  ].freeze

  belongs_to :eventable, polymorphic: true, touch: true

  validates :eventable,      presence: true # What is the subject of the event
  validates :type,           presence: true # STI class of the event
  validates :occurred_at,    presence: true # When did a human think the event occurred
  validates :recorded_at,    presence: true # When did supplier/frontend record the event
  validates :details,        presence: true # Details that are specific to each event.
  validates :created_by,     presence: true, inclusion: { in: CREATED_BY_OPTIONS }

  # This scope is used to determine the apply order of events as they were determined to have occurred.
  # The order is important as far as the eventable state machine sequencing, the correctness
  # of any attributes of the eventable and for reporting purposes.
  scope :applied_order, -> { order(occurred_at: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer

  # Default trigger behaviour for all events is to do nothing
  def trigger; end

  def for_feed
    attributes.slice(*FEED_ATTRIBUTES)
  end

  def self.from_event(event)
    type = "GenericEvent::#{event.eventable_type}#{event.event_name.capitalize}"

    type.constantize.from_event(event)
  end
end

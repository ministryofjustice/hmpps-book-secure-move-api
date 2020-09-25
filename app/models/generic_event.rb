class GenericEvent < ApplicationRecord
  FEED_ATTRIBUTES = %w[
    id
    type
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
    JourneyAdmitThroughOuterGate
    JourneyArriveAtOuterGate
    JourneyCancel
    JourneyComplete
    JourneyCreate
    JourneyExitThroughOuterGate
    JourneyHandoverToDestination
    JourneyLockout
    JourneyLodging
    JourneyPersonLeaveVehicle
    JourneyReadyToExit
    JourneyReject
    JourneyStart
    JourneyUncancel
    JourneyUncomplete
    JourneyUpdate
    MoveAccept
    MoveApprove
    MoveCancel
    MoveCollectionByEscort
    MoveComplete
    MoveLockout
    MoveLodgingEnd
    MoveLodgingStart
    MoveNotifyPremisesOfArrivalIn30Mins
    MoveNotifyPremisesOfEta
    MoveNotifyPremisesOfExpectedCollectionTime
    MoveOperationSafeguard
    MoveOperationTornado
    MoveRedirect
    MoveReject
    MoveStart
  ].freeze

  belongs_to :eventable, polymorphic: true, touch: true
  belongs_to :supplier,  optional: true

  validates :eventable,      presence: true # What is the subject of the event
  validates :type,           presence: true # STI class of the event
  validates :occurred_at,    presence: true # When did a human think the event occurred
  validates :recorded_at,    presence: true # When did supplier/frontend record the event

  # This scope is used to determine the apply order of events as they were determined to have occurred.
  # The order is important as far as the eventable state machine sequencing, the correctness
  # of any attributes of the eventable and for reporting purposes.
  scope :applied_order, -> { order(occurred_at: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer

  # Default trigger behaviour for all events is to do nothing
  def trigger; end

  def for_feed
    feed = attributes.slice(*FEED_ATTRIBUTES)
    feed.merge!(supplier&.for_feed) if supplier_id
    feed
  end

  def self.from_event(event)
    type = "GenericEvent::#{event.eventable_type}#{event.event_name.capitalize}"

    type.constantize.from_event(event)
  end
end

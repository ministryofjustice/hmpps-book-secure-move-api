class GenericEvent < ApplicationRecord
  FEED_ATTRIBUTES = %w[
    id
    notes
    created_at
    created_by
    updated_at
    occurred_at
    recorded_at
    eventable_id
    eventable_type
    details
  ].freeze

  STI_CLASSES = %w[
    JourneyAdmitThroughOuterGate
    JourneyAdmitToReception
    JourneyArriveAtOuterGate
    JourneyCancel
    JourneyChangeVehicle
    JourneyComplete
    JourneyCreate
    JourneyExitThroughOuterGate
    JourneyHandoverToDestination
    JourneyHandoverToSupplier
    JourneyLockout
    JourneyLodging
    JourneyPersonBoardsVehicle
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
    MoveCrossSupplierDropOff
    MoveCrossSupplierPickUp
    MoveDateChanged
    MoveLockout
    MoveLodgingEnd
    MoveLodgingStart
    MoveNotifyPremisesOfArrivalIn30Mins
    MoveNotifyPremisesOfEta
    MoveNotifyPremisesOfDropOffEta
    MoveNotifyPremisesOfPickupEta
    MoveNotifyPremisesOfExpectedCollectionTime
    MoveOperationHmcts
    MoveOperationSafeguard
    MoveOperationTornado
    MoveProposed
    MoveRedirect
    MoveReject
    MoveRequested
    MoveStart
    PerConfirmation
    PerCourtAllDocumentationProvidedToSupplier
    PerCourtAssignCellInCustody
    PerCourtCellShareRiskAssessment
    PerCourtExcessiveDelayNotDueToSupplier
    PerCourtHearing
    PerCourtPreReleaseChecksCompleted
    PerCourtReadyInCustody
    PerCourtRelease
    PerCourtReleaseOnBail
    PerCourtReturnToCustodyAreaFromDock
    PerCourtReturnToCustodyAreaFromVisitorArea
    PerCourtTakeFromCustodyToDock
    PerCourtTakeToSeeVisitors
    PerCourtTask
    PerGeneric
    PerHandover
    PerMedicalAid
    PerMedicalDrugsAlcohol
    PerMedicalMentalHealth
    PerPrisonerWelfare
    PerPropertyChange
    PersonMoveAssault
    PersonMoveBookedIntoReceivingEstablishment
    PersonMoveDeathInCustody
    PersonMoveMajorIncidentOther
    PersonMoveMinorIncidentOther
    PersonMovePersonEscaped
    PersonMovePersonEscapedKpi
    PersonMoveReleasedError
    PersonMoveRoadTrafficAccident
    PersonMoveSeriousInjury
    PersonMoveUsedForce
    PersonMoveVehicleBrokeDown
    PersonMoveVehicleSystemsFailed
  ].freeze

  enum classification: {
    default: 'default',
    incident: 'incident',
    medical: 'medical',
    notification: 'notification',
  }

  belongs_to :eventable, polymorphic: true, touch: true
  belongs_to :supplier,  optional: true

  validates :eventable,      presence: true # What is the subject of the event
  validates :type,           presence: true # STI class of the event
  validates :occurred_at,    presence: true # When did a human think the event occurred
  validates :recorded_at,    presence: true # When did supplier/frontend record the event

  validates :classification, inclusion: { in: classifications }

  # This scope is used to determine the apply order of events as they were determined to have occurred.
  # The order is important as far as the eventable state machine sequencing, the correctness
  # of any attributes of the eventable and for reporting purposes.
  scope :applied_order, -> { order(occurred_at: :asc) }

  serialize :details, HashWithIndifferentAccessSerializer

  before_validation :set_classification

  def event_type
    type&.gsub('GenericEvent::', '')
  end

  def event_classification
    :default
  end

  # Default trigger behaviour for all events is to do nothing
  def trigger(*); end

  def for_feed
    feed = attributes.slice(*FEED_ATTRIBUTES)
    feed.merge!('type' => type.sub('GenericEvent::', ''))
    feed.merge!(supplier&.for_feed) if supplier_id
    feed
  end

  def self.details_attributes(*attributes)
    define_singleton_method(:details_attributes) do
      instance_variable_get('@details_attributes')
    end

    instance_variable_set('@details_attributes', attributes)

    attributes.each do |attribute_key|
      define_method(attribute_key) do
        details[attribute_key]
      end

      define_method("#{attribute_key}=") do |attribute_value|
        details[attribute_key] = attribute_value
      end
    end
  end

  # NB: Majority of events will use this serializer rather than the anonymous class.
  def self.serializer
    GenericEventSerializer
  end

  # Relationship attributes live against the details but are expected in the json:api relationship section
  # so are defined separately
  def self.relationship_attributes(attributes)
    define_singleton_method(:relationship_attributes) do
      instance_variable_get('@relationship_attributes')
    end

    instance_variable_set('@relationship_attributes', attributes)

    define_singleton_method(:serializer) do
      @serializer ||=
        Class.new(GenericEventSerializer).tap do |new_serializer_class|
          relationship_attributes.each do |attribute_key, attribute_type|
            named_relationship_key = attribute_key.to_s.sub('_id', '')

            new_serializer_class.set_type :events
            new_serializer_class.has_one named_relationship_key, serializer: SerializerVersionChooser.call(attribute_type)
          end
        end
    end

    attributes.each do |attribute_key, attribute_type|
      named_relationship_key = attribute_key.to_s.sub('_id', '')

      define_method(attribute_key) do
        details[attribute_key]
      end

      define_method("#{attribute_key}=") do |attribute_value|
        details[attribute_key] = attribute_value
      end

      define_method(named_relationship_key) do
        id = details[attribute_key]
        model = attribute_type.to_s.singularize.camelize
        model.constantize.find_by(id: id)
      end
    end
  end

  def self.validate_occurs_before(*before_types)
    validate do
      before_types.each do |before_type|
        events = if before_type.constantize.eventable_types.include?(eventable_type)
                   eventable.generic_events
                 elsif eventable_type == 'Move'
                   eventable.all_events_for_timeline
                 elsif eventable_type == 'Journey'
                   eventable.move.all_events_for_timeline
                 else
                   eventable.generic_events
                 end
        next if events.where('occurred_at < ?', occurred_at).where(type: before_type).empty?

        # errors.add(:base, "#{type} may not occur after #{before_type}")
        Sentry.capture_message("#{type} occurred after #{before_type}", level: 'warning', extra: { supplier: supplier&.key, eventable_type: eventable_type, eventable_id: eventable_id })
        break
      end
    end
  end

  def self.validate_occurs_after(*after_types)
    validate do
      after_types.each do |after_type|
        events = if after_type.constantize.eventable_types.include?(eventable_type)
                   eventable.generic_events
                 elsif eventable_type == 'Move'
                   eventable.all_events_for_timeline
                 elsif eventable_type == 'Journey'
                   eventable.move.all_events_for_timeline
                 else
                   eventable.generic_events
                 end
        next if events.where('occurred_at > ?', occurred_at).where(type: after_type).empty?

        # errors.add(:base, "#{type} may not occur before #{after_type}")
        Sentry.capture_message("#{type} occurred before #{after_type}", level: 'warning', extra: { supplier: supplier&.key, eventable_type: eventable_type, eventable_id: eventable_id })
        break
      end
    end
  end

  def self.eventable_types(*types)
    define_singleton_method(:eventable_types) do
      instance_variable_get('@eventable_types')
    end

    validates :eventable_type, inclusion: { in: types }

    instance_variable_set('@eventable_types', types)
  end

private

  def set_classification
    self.classification = event_classification
  end
end

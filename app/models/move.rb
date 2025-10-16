# frozen_string_literal: true

class Move < VersionedModel
  FEED_ATTRIBUTES = %w[
    id
    date
    status
    created_at
    updated_at
    reference
    move_type
    additional_information
    time_due
    cancellation_reason
    cancellation_reason_comment
    profile_id
    prison_transfer_reason
    reason_comment
    move_agreed
    move_agreed_by
    date_from
    date_to
    allocation_id
    rejection_reason
    recall_date
  ].freeze

  include CancellationReasons
  include StateMachineable

  MOVE_STATUS_PROPOSED = 'proposed'
  MOVE_STATUS_REQUESTED = 'requested'
  MOVE_STATUS_BOOKED = 'booked'
  MOVE_STATUS_IN_TRANSIT = 'in_transit'
  MOVE_STATUS_COMPLETED = 'completed'
  MOVE_STATUS_CANCELLED = 'cancelled'

  NOMIS_STATUS_TYPES = {
    'SCH' => MOVE_STATUS_BOOKED,    # Scheduled == Booked
    'EXP' => MOVE_STATUS_REQUESTED, # TODO: 'exp' is believed to mean 'expired' - more analysis is required to decide how to handle this
    'COMP' => MOVE_STATUS_COMPLETED,
  }.freeze

  enum :status, {
    proposed: MOVE_STATUS_PROPOSED,
    requested: MOVE_STATUS_REQUESTED,
    booked: MOVE_STATUS_BOOKED,
    in_transit: MOVE_STATUS_IN_TRANSIT,
    completed: MOVE_STATUS_COMPLETED,
    cancelled: MOVE_STATUS_CANCELLED,
  }

  enum :move_type, {
    court_appearance: 'court_appearance',
    court_other: 'court_other',
    hospital: 'hospital',
    police_transfer: 'police_transfer',
    prison_recall: 'prison_recall',
    prison_remand: 'prison_remand',
    prison_transfer: 'prison_transfer',
    video_remand: 'video_remand',
    approved_premises: 'approved_premises',
    extradition: 'extradition',
  }

  REJECTION_REASONS = [
    REJECTION_REASON_NO_SPACE = 'no_space_at_receiving_prison',
    REJECTION_REASON_NO_TRANSPORT = 'no_transport_available',
    REJECTION_REASON_MORE_INFO = 'more_info_required',
  ].freeze

  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location', optional: true
  belongs_to :profile, optional: true, touch: true
  has_one :person, through: :profile
  has_one :person_escort_record
  has_one :youth_risk_assessment
  has_one :extradition_flight

  belongs_to :prison_transfer_reason, optional: true
  belongs_to :allocation, inverse_of: :moves, optional: true
  belongs_to :original_move, class_name: 'Move', optional: true

  has_many :notifications, as: :topic, dependent: :destroy # NB: polymorphic association
  has_many :journeys, -> { default_order }, dependent: :restrict_with_exception, inverse_of: :move
  has_many :lodgings, dependent: :restrict_with_exception, inverse_of: :move
  has_many :court_hearings, dependent: :restrict_with_exception

  has_many :generic_events, as: :eventable, dependent: :destroy
  has_many :incident_events, -> { where classification: :incident }, as: :eventable, class_name: 'GenericEvent'
  has_many :notification_events, -> { where classification: :notification }, as: :eventable, class_name: 'GenericEvent'
  has_many :cancellation_events, as: :eventable, class_name: 'GenericEvent::MoveCancel'

  validates :from_location, presence: true
  validates :to_location, presence: true, unless: -> { prison_recall? || video_remand? }
  validates_with DifferentToFromLocationValidator, unless: -> { generic_events.where(type: 'GenericEvent::MoveLockout').any? }

  validates :move_type, inclusion: { in: move_types }
  validates_with Moves::MoveTypeValidator

  validates :profile, presence: true, if: -> { proposed? || in_transit? || completed? }
  validates :reference, presence: true

  validate :validate_move_uniqueness, unless: -> { proposed? || cancelled? || profile_id.nil? }

  validates :date, presence: true, unless: -> { proposed? || cancelled? }
  validates :date_from, presence: true, if: :proposed?
  validates :status, inclusion: { in: statuses }

  validates :cancellation_reason, inclusion: { in: CANCELLATION_REASONS }, if: :cancelled?
  validates :cancellation_reason, absence: true, unless: :cancelled?

  validates :rejection_reason, inclusion: { in: REJECTION_REASONS }, allow_nil: true, if: :rejected?
  validates :rejection_reason, absence: true, unless: :rejected?

  validate :date_to_after_date_from
  validate :validate_prisoner_category
  validate :validate_date_change_allocation, on: :update, unless: -> { validation_context == :update_allocation }

  validates :recall_date, date: true

  validates :move_type,
            exclusion: {
              in: %w[extradition],
              message: '%{value} is only valid if extradition_capable is true for destination location',
            },
            unless: -> { to_location&.extradition_capable }

  before_validation :set_reference
  before_validation :set_move_type

  after_update :cancel_proposed_journeys

  delegate :suppliers, to: :from_location

  attr_accessor :version

  has_state_machine MoveStateMachine, on: :status

  delegate :accept,
           :complete,
           :proposed?,
           :requested?,
           :booked?,
           :in_transit?,
           :completed?,
           :cancelled?,
           to: :state_machine

  def self.for_supplier(supplier)
    where(supplier:)
      .or(Move.where(from_location: supplier.locations))
      .or(Move.where(to_location: supplier.locations))
      .or(Move.where(id: Move.joins(:lodgings).where('lodgings.location' => supplier.locations)))
  end

  def approve(date:)
    return unless state_machine.approve

    assign_attributes(date:) if date.present?
  end

  def approve!(args)
    approve(args)
    save!
  end

  def cancel(cancellation_reason:, cancellation_reason_comment: nil)
    assign_attributes(
      cancellation_reason:,
      cancellation_reason_comment:,
    )
    state_machine.cancel
  end

  def cancel!(**args)
    cancel(**args)
    save!
  end

  def reject(rejection_reason:, cancellation_reason_comment: nil)
    assign_attributes(
      rejection_reason:,
      cancellation_reason: Move::CANCELLATION_REASON_REJECTED,
      cancellation_reason_comment:,
    )
    state_machine.reject
  end

  def reject!(args)
    reject(args)
    save!
  end

  def start
    # if the move is being started and the PER is completed but not yet confirmed, then auto-confirm it
    # move started
    if state_machine.start && person_escort_record.present? && person_escort_record.completed?
      now = Time.zone.now

      person_escort_record.generic_events << GenericEvent::PerConfirmation.new(
        occurred_at: now,
        recorded_at: now,
        notes: 'Automatically confirmed on move start',
        details: { confirmed_at: now },
      )
      person_escort_record.confirm!(FrameworkAssessmentable::ASSESSMENT_CONFIRMED)
      Notifier.prepare_notifications(topic: person_escort_record, action_name: 'confirm_person_escort_record')
    end
  end

  def infer_status_transition(new_status, cancellation_reason: nil, cancellation_reason_comment: nil, rejection_reason: nil, date: nil)
    # NB: for historic reasons it is still possible for a client to manually update a move's status (without an associated event).
    # If the client is attempting to update a move's status, compare the before and after status to infer the correct
    # state transition and apply that via the move's state machine.

    transition = { status => new_status }
    case transition
    when { Move::MOVE_STATUS_PROPOSED => Move::MOVE_STATUS_REQUESTED }
      approve(date:)
    when { Move::MOVE_STATUS_REQUESTED => Move::MOVE_STATUS_BOOKED }
      accept
    when { Move::MOVE_STATUS_BOOKED => Move::MOVE_STATUS_IN_TRANSIT }
      start
    when { Move::MOVE_STATUS_IN_TRANSIT => Move::MOVE_STATUS_COMPLETED }
      complete
    when { Move::MOVE_STATUS_PROPOSED => Move::MOVE_STATUS_CANCELLED }, { Move::MOVE_STATUS_REQUESTED => Move::MOVE_STATUS_CANCELLED }
      # NB: Usually Proposed --> Cancelled is a Rejection; however some systems may still expect this to be a cancellation
      # NB: Usually Requested --> Cancelled is a Rejection; however some systems may still expect this to be a cancellation
      if cancellation_reason.present?
        cancel(cancellation_reason:, cancellation_reason_comment:)
      elsif rejection_reason.present?
        reject(rejection_reason:, cancellation_reason_comment:)
      end
    when { Move::MOVE_STATUS_BOOKED => Move::MOVE_STATUS_CANCELLED }
      cancel(cancellation_reason:, cancellation_reason_comment:)
    end
  end

  # TODO: Temporary method to apply correct validation rules when creating v2 move
  def v2?
    version == 2
  end

  def rebooked
    self.class.find_by(original_move_id: id)
  end

  def rebook
    return rebooked if rebooked.present?

    Move.create!(
      original_move_id: id,
      from_location_id:,
      to_location_id:,
      allocation_id:,
      profile_id:,
      status: MOVE_STATUS_PROPOSED,
      date: date && date + 7.days,
      date_from: date_from && date_from + 7.days,
      date_to: date_to && date_to + 7.days,
      supplier:,
    )
  end

  def self.unfilled?
    none? || exists?(profile_id: nil)
  end

  def rejected?
    cancellation_reason == CANCELLATION_REASON_REJECTED
  end

  def active_lodgings
    lodgings.not_cancelled
  end

  def existing_moves
    Move
        .joins(:profile)
        .where('profiles.person_id = ?', profile.person_id)
        .not_cancelled
        .not_proposed
        .where(
          from_location_id:,
          to_location_id:,
          date:,
        )
        .where.not(profile: nil)
        .where.not(id:) # When updating an existing move, don't consider self a duplicate
  end

  def existing_id
    existing_moves&.first&.id
  end

  def current?
    # NB: a current move relates to a move happening today or in the future (as opposed to a back-dated or historic move)
    (date.present? && date >= Time.zone.today) ||
      (date.nil? && date_to.present? && date_to >= Time.zone.today) ||
      (date.nil? && date_to.nil? && date_from.present? && date_from >= Time.zone.today)
  end

  def for_feed
    feed_attributes = attributes.slice(*FEED_ATTRIBUTES)

    feed_attributes.merge!(from_location.for_feed(prefix: :from))
    feed_attributes.merge!(to_location.for_feed(prefix: :to)) if to_location
    feed_attributes.merge!(supplier.for_feed) if supplier

    feed_attributes['person_escort_record_id'] = person_escort_record_id if person_escort_record_id.present?
    feed_attributes['youth_risk_assessment_id'] = youth_risk_assessment_id if youth_risk_assessment_id.present?

    feed_attributes
  end

  def handle_event_run(dry_run: false)
    if changed? && !dry_run
      action_name = status_changed? ? 'update_status' : 'update'

      save! # save before notifying

      allocation&.refresh_status_and_moves_count!

      Notifier.prepare_notifications(topic: self, action_name:)
      true
    else
      false
    end
  end

  def all_events_for_timeline
    eventable_ids = [id, profile&.person_escort_record_id, profile&.person_id].compact
    eventable_ids += journeys.pluck(:id)
    eventable_ids += lodgings.pluck(:id)

    eventable_types = %w[Move PersonEscortRecord Person Journey Lodging]

    GenericEvent.where(eventable_type: eventable_types, eventable_id: eventable_ids).applied_order
  end

  def important_events
    eventable_ids = [id, profile&.person_escort_record_id].compact
    eventable_types = %w[Move PersonEscortRecord]

    events = GenericEvent.where(eventable_type: eventable_types, eventable_id: eventable_ids)

    medical_or_incident_events = events.where(classification: %w[medical incident suicide_and_self_harm])
    other_events = events.where(type: [
      GenericEvent::PerHandover,
      GenericEvent::PerPropertyChange,
      GenericEvent::MoveLodgingStart,
      GenericEvent::MoveLodgingEnd,
    ].map(&:name))

    # This is more performant that doing an `OR` in SQL as the query planner gets confused by the lack of an index for the type column
    medical_or_incident_events + other_events
  end

  def vehicle_registration
    # Process in memory to avoid n+1 queries in serializers
    journeys
      .reject(&:cancelled?)
      .max_by(&:client_timestamp)
      &.vehicle
      &.dig('registration')
  end

  def expected_time_of_arrival
    # Process in memory to avoid n+1 queries in serializers
    generic_events.select { |event| event.type == 'GenericEvent::MoveNotifyPremisesOfDropOffEta' }.max_by(&:occurred_at)&.expected_at
  end

  def expected_collection_time
    # Process in memory to avoid n+1 queries in serializers
    # TODO: use GenericEvent::MoveNotifyPremisesOfPickupEta when it is available
    generic_events.select { |event| event.type == 'GenericEvent::MoveNotifyPremisesOfExpectedCollectionTime' }.max_by(&:occurred_at)&.expected_at
  end

  def cross_supplier?
    from_location&.suppliers != to_location&.suppliers
  end

  def billable?
    journeys.select(&:billable?).any?
  end

  def prisoner_location_description
    PrisonerSearchApiClient::LocationDescription.get(person.prison_number) if person&.prison_number
  end

private

  def date_to_after_date_from
    if date_from.present? && date_to.present? && (date_to < date_from)
      errors.add(:date_to, 'must be after date from')
    end
  end

  def set_reference
    self.reference ||= Moves::ReferenceGenerator.new.call
  end

  def set_move_type
    return if move_type.present? || v2?

    # TODO: The order is not important, here.
    #       Remove this from the model when we migrate to mandatory move_type under v2
    self.move_type = if is_a_prison_recall?
                       'prison_recall'
                     elsif is_a_court_appearance?
                       'court_appearance'
                     elsif is_a_police_tranfer?
                       'police_transfer'
                     else
                       'prison_transfer'
                     end
  end

  def is_a_police_tranfer?
    to_location&.police? && from_location&.police?
  end

  def is_a_prison_recall?
    to_location.nil?
  end

  def is_a_court_appearance?
    to_location&.court?
  end

  def validate_move_uniqueness
    errors.add(:date, :taken) if existing_moves.any?
  end

  def validate_prisoner_category
    if profile&.category&.move_supported == false
      errors.add(:profile, :unsupported_prisoner_category, message: "person is a category '#{profile.category.key}' prisoner and cannot be moved using this service")
    end
  end

  def validate_date_change_allocation
    if date_changed? && allocation
      errors.add(:date, :cant_change_allocation, message: 'cannot be changed as move is part of an allocation')
    end
  end

  # TODO: This should be temporary until Serco automatically reject/update journeys on MoveDateChange
  def cancel_proposed_journeys
    return if !saved_change_to_date? || date.blank? || date_before_last_save.blank?

    journeys.each do |journey|
      next if journey.state != 'proposed' || journey.date.blank? || journey.date != date_before_last_save

      journey.date = date
      journey.save!
    end
  end
end

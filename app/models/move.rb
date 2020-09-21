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
  ].freeze

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

  enum status: {
    proposed: MOVE_STATUS_PROPOSED,
    requested: MOVE_STATUS_REQUESTED,
    booked: MOVE_STATUS_BOOKED,
    in_transit: MOVE_STATUS_IN_TRANSIT,
    completed: MOVE_STATUS_COMPLETED,
    cancelled: MOVE_STATUS_CANCELLED,
  }

  enum move_type: {
    court_appearance: 'court_appearance',
    court_other: 'court_other',
    hospital: 'hospital',
    police_transfer: 'police_transfer',
    prison_recall: 'prison_recall',
    prison_remand: 'prison_remand',
    prison_transfer: 'prison_transfer',
    video_remand: 'video_remand',
  }

  CANCELLATION_REASONS = [
    CANCELLATION_REASON_MADE_IN_ERROR = 'made_in_error',
    CANCELLATION_REASON_SUPPLIER_DECLINED_TO_MOVE = 'supplier_declined_to_move',
    CANCELLATION_REASON_CANCELLED_BY_PMU = 'cancelled_by_pmu',
    CANCELLATION_REASON_REJECTED = 'rejected',
    CANCELLATION_REASON_OTHER = 'other',
  ].freeze

  REJECTION_REASONS = [
    REJECTION_REASON_NO_SPACE = 'no_space_at_receiving_prison',
    REJECTION_REASON_NO_TRANSPORT = 'no_transport_available',
  ].freeze

  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location', optional: true
  belongs_to :profile, optional: true, touch: true
  has_one :person, through: :profile

  belongs_to :prison_transfer_reason, optional: true
  belongs_to :allocation, inverse_of: :moves, optional: true
  belongs_to :original_move, class_name: 'Move', optional: true

  has_many :notifications, as: :topic, dependent: :destroy # NB: polymorphic association
  has_many :journeys, -> { default_order }, dependent: :restrict_with_exception, inverse_of: :move
  has_many :court_hearings, dependent: :restrict_with_exception
  has_many :move_events, as: :eventable, dependent: :destroy # NB: polymorphic association

  validates :from_location, presence: true
  validates :to_location, presence: true, unless: -> { prison_recall? || video_remand? }
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

  before_validation :set_reference
  before_validation :set_move_type

  delegate :suppliers, to: :from_location

  scope :not_cancelled, -> { where.not(status: MOVE_STATUS_CANCELLED) }

  attr_accessor :version

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
      from_location_id: from_location_id,
      to_location_id: to_location_id,
      allocation_id: allocation_id,
      profile_id: profile_id,
      status: MOVE_STATUS_PROPOSED,
      date: date && date + 7.days,
      date_from: date_from && date_from + 7.days,
      date_to: date_to && date_to + 7.days,
      supplier: supplier,
    )
  end

  def self.unfilled?
    none? || exists?(profile_id: nil)
  end

  def rejected?
    cancellation_reason == CANCELLATION_REASON_REJECTED
  end

  def existing
    self.class.not_cancelled.find_by(date: date, profile_id: profile_id, from_location_id: from_location_id, to_location_id: to_location_id)
  end

  def existing_id
    existing&.id
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

    feed_attributes
  end

private

  def date_to_after_date_from
    if date_from.present? && date_to.present?
      if date_to < date_from
        errors.add(:date_to, 'must be after date from')
      end
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
    existing_moves = Move.joins(:profile)
      .where('profiles.person_id = ?', profile.person_id)
      .where(
        status: status,
        from_location_id: from_location_id,
        to_location_id: to_location_id,
        date: date,
      )
      .where.not(id: id) # When updating an existing move, don't consider self a duplicate

    errors.add(:date, :taken) if existing_moves.any?
  end
end

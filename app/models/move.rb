# frozen_string_literal: true

class Move < VersionedModel
  MOVE_STATUS_PROPOSED = 'proposed'
  MOVE_STATUS_REQUESTED = 'requested'
  MOVE_STATUS_COMPLETED = 'completed'
  MOVE_STATUS_CANCELLED = 'cancelled'

  NOMIS_STATUS_TYPES = {
    'SCH' => MOVE_STATUS_REQUESTED,
    'EXP' => MOVE_STATUS_REQUESTED,
    'COMP' => MOVE_STATUS_COMPLETED,
  }.freeze

  enum status: {
    proposed: MOVE_STATUS_PROPOSED,
    requested: MOVE_STATUS_REQUESTED,
    completed: MOVE_STATUS_COMPLETED,
    cancelled: MOVE_STATUS_CANCELLED,
  }

  enum move_type: {
    court_appearance: 'court_appearance',
    prison_recall: 'prison_recall',
    prison_transfer: 'prison_transfer',
  }

  MOVE_CANCELLATION_REASON_MADE_IN_ERROR = 'made_in_error'

  enum cancellation_reason: {
    made_in_error: MOVE_CANCELLATION_REASON_MADE_IN_ERROR,
    supplier_declined_to_move: 'supplier_declined_to_move',
    other: 'other',
  }

  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location', optional: true
  belongs_to :profile, optional: true
  belongs_to :prison_transfer_reason, optional: true
  belongs_to :allocation, inverse_of: :moves, optional: true
  # using https://github.com/jhawthorn/discard for documents, so only include the non-soft-deleted documents here
  has_many :documents, -> { kept }, dependent: :destroy, inverse_of: :move
  has_many :notifications, as: :topic, dependent: :destroy # NB: polymorphic association
  has_many :journeys, -> { default_order }, dependent: :restrict_with_exception, inverse_of: :move
  has_many :court_hearings, dependent: :restrict_with_exception
  has_many :events, as: :eventable, dependent: :destroy # NB: polymorphic association

  validates :from_location, presence: true
  validates(
    :to_location,
    presence: true,
    unless: ->(move) { move.move_type == 'prison_recall' },
  )
  validates :move_type, inclusion: { in: move_types }
  validates :profile, presence: true, unless: -> { [MOVE_STATUS_REQUESTED, MOVE_STATUS_CANCELLED].include?(status) }
  validates :reference, presence: true

  # we need to avoid creating/updating a move with the same profile/date/from/to if there is already one in the same state
  # except that we need to allow multiple cancelled moves
  validates :date, uniqueness: { scope: %i[status profile_id from_location_id to_location_id] },
            unless: -> { [MOVE_STATUS_PROPOSED, MOVE_STATUS_CANCELLED].include?(status) || profile_id.blank? }
  validates :date, presence: true,
            unless: -> { status == MOVE_STATUS_PROPOSED }
  validates :date_from, presence: true,
            if: -> { status == MOVE_STATUS_PROPOSED }

  validate :date_to_after_date_from

  validates :status, inclusion: { in: statuses }

  before_validation :set_reference
  before_validation :set_move_type
  before_validation :ensure_event_nomis_ids_uniqueness

  delegate :suppliers, to: :from_location

  scope :served_by, ->(supplier_id) { where('from_location_id IN (?)', Location.supplier(supplier_id).pluck(:id)) }
  scope :not_cancelled, -> { where.not(status: MOVE_STATUS_CANCELLED) }

  def nomis_event_id=(event_id)
    nomis_event_ids << event_id
  end

  def from_nomis?
    !nomis_event_ids.empty?
  end

  def existing
    self.class.not_cancelled.find_by(date: date, profile_id: profile_id, from_location_id: from_location_id, to_location_id: to_location_id)
  end

  def existing_id
    existing&.id
  end

  def current?
    # NB: a current move relates to a move happening today or in the future (as opposed to a back-dated or historic move)
    (self.date.present? && self.date >= Time.zone.today) ||
      (self.date.nil? && self.date_to.present? && self.date_to >= Time.zone.today) ||
      (self.date.nil? && self.date_to.nil? && self.date_from.present? && self.date_from >= Time.zone.today)
  end

  def person
    raise 'Attempt to Access to person!!!'
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
    return if move_type.present?

    self.move_type =
      if to_location.nil?
        'prison_recall'
      elsif to_location_is_court?
        'court_appearance'
      else
        'prison_transfer'
      end
  end

  def ensure_event_nomis_ids_uniqueness
    nomis_event_ids.uniq!
  end

  def to_location_is_court?
    to_location&.location_type == 'court'
  end
end

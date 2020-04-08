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
  belongs_to :person
  belongs_to :prison_transfer_reason, optional: true
  # using https://github.com/jhawthorn/discard for documents, so only include the non-soft-deleted documents here
  has_many :documents, -> { kept }, dependent: :destroy, inverse_of: :move
  has_many :notifications, as: :topic, dependent: :destroy # NB: polymorphic association
  has_many :court_hearings

  validates :from_location, presence: true
  validates(
    :to_location,
    presence: true,
    unless: ->(move) { move.move_type == 'prison_recall' },
  )
  validates :date, presence: true
  validates :move_type, inclusion: { in: move_types }
  validates :person, presence: true
  validates :reference, presence: true

  validates :status, inclusion: { in: statuses }
  # we need to avoid creating/updating a move with the same person/date/from/to if there is already one in the same state
  # except that we need to allow multiple cancelled moves
  validates :date, uniqueness: { scope: %i[status person_id from_location_id to_location_id] },
            unless: -> { status == MOVE_STATUS_CANCELLED }

  validate :date_to_after_date_from

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
    self.class.not_cancelled.find_by(date: date, person_id: person_id, from_location_id: from_location_id, to_location_id: to_location_id)
  end

  def existing_id
    existing&.id
  end

  def from_prison_to_court?
    from_location.try(:prison?) && to_location.try(:court?)
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

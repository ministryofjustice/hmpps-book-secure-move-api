# A Journey is the path (or intended path) between two locations.
#
# A Move is composed of one or more Journeys; each individual journey record indicates the path and whether it is billable.
# Moves can be redirected for various reasons (e.g. supplier is late and the prison is closed; or the PMU call to say the prison is full and
# the person should be taken to a different location). Sometimes these journeys are billable and sometimes not.
#
# Journeys are ordered chronologically by client_timestamp (as opposed to created_at), to allow for queueing and transmission delays in the system sending the journey record.
# Journeys have an explicit link to a supplier; whereas moves currently do not.
#
# Example 1: a move: A--> B is redirected to C by PMU before the supplier arrives at B.
# Journey1: A --> B (billable, cancelled)
# Journey2: B --> C (billable, completed)
# The supplier is paid for two journeys A-->B and B-->C.
#
# Example 2: a move: A--> B is redirected to C because the supplier arrived late and was locked out.
# Journey1: A --> B (billable, completed)
# Journey2: B --> C (not billable, completed)
# The supplier is paid for only the first journey A-->B but not B-->C.
#
class Journey < VersionedModel
  FEED_ATTRIBUTES = %w[
    id
    move_id
    billable
    state
    date
    vehicle_registration
    client_timestamp
    created_at
    updated_at
  ].freeze

  include StateMachineable

  belongs_to :move, touch: true
  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  has_many :generic_events, as: :eventable, dependent: :destroy

  attribute :states, :string
  enum :states, {
    proposed: 'proposed',
    rejected: 'rejected',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
  }

  validates :move, presence: true
  validates :supplier, presence: true
  validates :from_location, presence: true
  validates :to_location, presence: true
  validates_with DifferentToFromLocationValidator
  validates :client_timestamp, presence: true
  validates :billable, exclusion: { in: [nil] }
  validates :state, presence: true, inclusion: { in: states }

  scope :default_order, -> { order(client_timestamp: :asc) }
  scope :not_rejected_or_cancelled, -> { where.not(state: %i[rejected cancelled]) }

  has_state_machine JourneyStateMachine

  delegate :start,
           :reject,
           :complete,
           :uncomplete,
           :cancel,
           :uncancel,
           :proposed?,
           :in_progress?,
           :completed?,
           :cancelled?,
           :rejected?,
           to: :state_machine

  def for_feed
    attributes.slice(*FEED_ATTRIBUTES)
      .merge(from_location.for_feed(prefix: :from))
      .merge(to_location.for_feed(prefix: :to))
      .merge(supplier.for_feed)
      .merge(vehicle_registration:)
      .merge(vehicle_depot:)
  end

  def vehicle_registration
    vehicle['registration'] if vehicle
  end

  def vehicle_registration=(reg)
    (self.vehicle ||= {})['registration'] = reg
  end

  def vehicle_depot
    vehicle['depot'] if vehicle
  end

  def vehicle_depot=(reg)
    (self.vehicle ||= {})['depot'] = reg
  end

  def handle_event_run(dry_run: false)
    save! if changed? && valid? && !dry_run
  end

  def number
    @number ||= (move.journeys.default_order.pluck(:id).index(id) + 1)
  end
end

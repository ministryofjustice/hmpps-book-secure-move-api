class Journey < ApplicationRecord
  belongs_to :move
  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  validates :move, presence: true
  validates :supplier, presence: true
  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :client_timestamp, presence: true
  validates :billable, exclusion: { in: [nil] }
  validates :state, presence: true, inclusion: { in: %w(in_progress completed cancelled) }

  scope :default_order, -> { order(client_timestamp: :desc) }

  before_validation :set_state_from_state_machine, on: :create
  after_find :restore_state_machine
  after_initialize :restore_state_machine # NB there is an equivalent after(:build) callback for FactoryBot in the journeys factory

  delegate :complete, :un_complete, :cancel, :un_cancel, to: :state_machine

private

  def state_machine
    @state_machine ||= JourneyStateMachine.new(self)
  end

  # syncs record to state_machine
  def set_state_from_state_machine(new_state = state_machine.current)
    self.state = new_state
  end

  # syncs state_machine to record
  def restore_state_machine
    state_machine.restore!(state.to_sym) if state.present?
  end
end

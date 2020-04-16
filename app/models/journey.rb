class Journey < ApplicationRecord
  belongs_to :move
  belongs_to :supplier
  belongs_to :from_location, class_name: 'Location'
  belongs_to :to_location, class_name: 'Location'

  enum states: {
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
  }

  validates :move, presence: true
  validates :supplier, presence: true
  validates :from_location, presence: true
  validates :to_location, presence: true
  validates :client_timestamp, presence: true
  validates :billable, exclusion: { in: [nil] }
  validates :state, presence: true, inclusion: { in: states }

  scope :default_order, -> { order(client_timestamp: :asc) }

  delegate :complete, :uncomplete, :cancel, :uncancel, to: :state_machine

  after_initialize :initialize_state # NB there is an equivalent after(:build) callback used by FactoryBot in the journeys factory

private

  def state_machine
    @state_machine ||= JourneyStateMachine.new(self)
  end

  def initialize_state
    if state.present?
      # set the internal state_machine to the state, if specified
      state_machine.restore!(state.to_sym)
    else
      # set the state to the state_machine's initial state
      self.state = state_machine.current
    end
  end
end

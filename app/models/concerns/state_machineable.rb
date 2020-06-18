require 'active_support/concern'

module StateMachineable
  extend ActiveSupport::Concern

  included do
    after_initialize :initialize_state

    class_attribute :state_attribute
    class_attribute :state_machine_class
  end

  def reload(options = nil)
    # Override to ensure state machine state is correctly restored. Unfortunately there's not a callback for this.
    super.tap { initialize_state }
  end

  def initialize_state
    state = self[state_attribute]
    if state.present?
      state_machine.restore!(state.to_sym)
    else
      self[state_attribute] = state_machine.current
    end
  end

  def state_machine
    @state_machine ||= state_machine_class.new(self)
  end

  class_methods do
    def has_state_machine(state_machine_class, options = {})
      self.state_machine_class = state_machine_class
      self.state_attribute = options[:on] || :state
    end
  end
end

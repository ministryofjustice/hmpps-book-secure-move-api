class JourneyStateMachine < FiniteMachine::Definition
  initial :in_progress

  event :complete, in_progress: :completed
  event :uncomplete, completed: :in_progress
  event :cancel, in_progress: :cancelled
  event :uncancel, cancelled: :in_progress

  on_enter do |event|
    target.state = event.to
  end
end

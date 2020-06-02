class JourneyStateMachine < FiniteMachine::Definition
  initial :proposed

  event :start, proposed: :in_progress
  event :reject, proposed: :rejected

  event :complete, in_progress: :completed
  event :uncomplete, completed: :in_progress

  event :cancel, in_progress: :cancelled
  event :uncancel, cancelled: :in_progress

  on_enter do |event|
    target.state = event.to
  end
end

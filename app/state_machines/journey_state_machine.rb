class JourneyStateMachine < FiniteMachine::Definition
  initial :in_progress

  event :complete, in_progress:  :completed
  event :un_complete, completed: :in_progress
  event :cancel, in_progress:    :cancelled
  event :un_cancel, cancelled:   :in_progress

  on_enter do |event|
    target.state = event.to
  end
end

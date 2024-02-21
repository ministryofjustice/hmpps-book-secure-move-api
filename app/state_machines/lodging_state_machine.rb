class LodgingStateMachine < FiniteMachine::Definition
  initial :proposed

  event :start, proposed: :started
  event :complete, started: :completed

  event :cancel, proposed: :cancelled

  on_enter do |event|
    target.status = event.to
  end
end

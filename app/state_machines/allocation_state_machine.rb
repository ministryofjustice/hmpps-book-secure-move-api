class AllocationStateMachine < FiniteMachine::Definition
  initial :unfilled

  event :fill, unfilled: :filled
  event :unfill, filled: :unfilled
  event :cancel, %i[unfilled filled] => :cancelled

  terminal :cancelled

  on_enter do |event|
    target.status = event.to
  end
end

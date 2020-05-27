class AllocationStateMachine < FiniteMachine::Definition
  initial :unfilled

  event :fill, %i[none unfilled filled] => :filled
  event :unfill, %i[none unfilled filled] => :unfilled
  event :cancel, %i[none unfilled filled] => :cancelled

  on_enter do |event|
    target.status = event.to
  end
end

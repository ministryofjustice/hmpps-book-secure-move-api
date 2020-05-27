class AllocationStateMachine < FiniteMachine::Definition
  initial :unfilled

  event :fill, %i[none unfilled filled] => :filled
  event :unfill, %i[none unfilled filled] => :unfilled

  on_enter do |event|
    target.status = event.to
  end
end

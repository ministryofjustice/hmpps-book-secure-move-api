class MoveStateMachine < FiniteMachine::Definition
  initial :proposed

  event :approve, proposed: :requested
  event :reject, proposed: :cancelled

  event :accept, requested: :booked
  event :reject, requested: :cancelled

  event :cancel, booked: :cancelled
  event :start, booked: :in_transit

  event :complete, in_transit: :completed
  event :cancel, requested: :cancelled # NB requested --Cancel--> cancelled is not a formally specified transition
  event :cancel, in_transit: :cancelled # NB in_transit --Cancel--> cancelled is not a formally specified transition

  on_enter do |event|
    target.status = event.to
  end
end

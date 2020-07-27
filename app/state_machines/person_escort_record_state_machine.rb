class PersonEscortRecordStateMachine < FiniteMachine::Definition
  initial :unstarted

  event :complete, %i[unstarted in_progress completed] => :completed
  event :uncomplete, %i[unstarted in_progress completed] => :in_progress
  event :confirm, completed: :confirmed

  terminal :confirmed

  on_enter do |event|
    target.status = event.to
  end

  on_after :confirm do
    target.confirmed_at = Time.zone.now
  end
end

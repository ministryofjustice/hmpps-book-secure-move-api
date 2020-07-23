class PersonEscortRecordStateMachine < FiniteMachine::Definition
  initial :unstarted

  event :complete, %i[unstarted in_progress] => :completed
  event :uncomplete, %i[unstarted completed] => :in_progress
  event :confirm, completed: :confirmed
  event :to_print, confirmed: :printed

  terminal :printed

  on_enter do |event|
    target.state = event.to
  end
end

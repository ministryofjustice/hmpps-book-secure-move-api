class PersonEscortRecordStateMachine < FiniteMachine::Definition
  initial :unstarted

  event :complete, %i[unstarted in_progress completed] => :completed
  event :uncomplete, %i[unstarted in_progress completed] => :in_progress
  event :confirm, completed: :confirmed
  event :to_print, confirmed: :printed

  terminal :printed

  on_enter do |event|
    target.state = event.to
  end

  on_after :confirm do
    target.confirmed_at = Time.zone.now
  end

  on_after :to_print do
    target.printed_at = Time.zone.now
  end
end

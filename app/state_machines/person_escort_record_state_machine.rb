class PersonEscortRecordStateMachine < FiniteMachine::Definition
  initial :unstarted

  event :calculate, %i[unstarted in_progress completed] => :completed, if: ->(_context, progress) { progress == PersonEscortRecord::PERSON_ESCORT_RECORD_COMPLETED }
  event :calculate, %i[unstarted in_progress completed] => :in_progress, if: ->(_context, progress) { progress == PersonEscortRecord::PERSON_ESCORT_RECORD_IN_PROGRESS }
  event :confirm, completed: :confirmed

  terminal :confirmed

  on_enter do |event|
    target.status = event.to
  end

  on_after :confirm do
    target.confirmed_at = Time.zone.now
  end
end

class FrameworkAssessmentStateMachine < FiniteMachine::Definition
  initial :unstarted

  event :calculate, %i[unstarted in_progress completed] => :completed, if: ->(_context, progress) { progress == FrameworkAssessmentable::ASSESSMENT_COMPLETED }
  event :calculate, %i[unstarted in_progress completed] => :in_progress, if: ->(_context, progress) { progress == FrameworkAssessmentable::ASSESSMENT_IN_PROGRESS }
  event :confirm, completed: :confirmed

  terminal :confirmed

  on_enter do |event|
    target.status = event.to
  end

  on_after :calculate do
    if completed?
      target.amended_at = Time.zone.now if target.respond_to?(:amended_at) && target.completed_at.present?

      if target.completed_at.nil?
        target.completed_at = Time.zone.now

        if target.is_a?(PersonEscortRecord)
          target.generic_events << GenericEvent::PerCompletion.new(
            occurred_at: Time.zone.now,
            recorded_at: Time.zone.now,
            details: { completed_at: Time.zone.now },
          )
        end
      end
    end
  end

  on_after :confirm do
    target.confirmed_at = Time.zone.now
  end
end

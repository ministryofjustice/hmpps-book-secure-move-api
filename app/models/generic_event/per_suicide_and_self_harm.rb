class GenericEvent
  class PerSuicideAndSelfHarm < GenericEvent
    details_attributes :concerns, :history, :method, :source, :source_summary, :source_observations,
                       :safety_actions, :observation_level, :comments,
                       :reporting_officer, :reporting_officer_signed_at,
                       :reception_officer, :reception_officer_signed_at

    eventable_types 'PersonEscortRecord'

    def event_classification
      :medical
    end
  end
end

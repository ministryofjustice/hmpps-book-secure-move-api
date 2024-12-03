class GenericEvent
  class PerSuicideAndSelfHarm < GenericEvent
    details_attributes :concern_intent,
                       :concern_reaction,
                       :concern_attempt,
                       :concern_someone,
                       :concern_pre_sentence,
                       :concern_behavioural,
                       :concern_other,
                       :history,
                       :method_ligature,
                       :method_cutting,
                       :method_overdose,
                       :method_other,
                       :method_unknown,
                       :source,
                       :source_summary,
                       :source_observations,
                       :safety_actions,
                       :share_cell,
                       :conversation,
                       :acct_plan,
                       :referred_medical,
                       :other_support,
                       :other_actions_taken,
                       :no_actions_taken,
                       :observation_level,
                       :comments,
                       :reporting_officer,
                       :reporting_officer_signed_at,
                       :reception_officer,
                       :reception_officer_signed_at

    eventable_types 'PersonEscortRecord'

    def event_classification
      :suicide_and_self_harm
    end
  end
end

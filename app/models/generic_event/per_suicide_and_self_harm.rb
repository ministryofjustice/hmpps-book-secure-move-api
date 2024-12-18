class GenericEvent
  class PerSuicideAndSelfHarm < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :indication_of_self_harm_or_suicide,
                       :nature_of_self_harm,
                       :history_of_self_harm,
                       :history_of_self_harm_recency,
                       :history_of_self_harm_method,
                       :history_of_self_harm_details,
                       :actions_of_self_harm_undertaken,
                       :observation_level,
                       :comments,
                       :reporting_officer,
                       :reporting_officer_signed_at,
                       :reception_officer,
                       :reception_officer_signed_at,
                       :supplier_personnel_number,
                       :police_personnel_number

    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include PersonnelNumberValidations
    include LocationFeed
    include LocationValidations

    def event_classification
      :suicide_and_self_harm
    end
  end
end

class GenericEvent
  class PerCourtCellShareRiskAssessment < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include LocationValidations
    include LocationFeed
  end
end

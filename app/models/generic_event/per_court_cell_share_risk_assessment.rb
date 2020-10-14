class GenericEvent
  class PerCourtCellShareRiskAssessment < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    relationship_attributes :location_id

    include PersonEscortRecordEventValidations
    include LocationValidations
  end
end

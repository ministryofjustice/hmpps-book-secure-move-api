class GenericEvent
  class PerCourtCellShareRiskAssessment < GenericEvent
    include PersonEscortRecordEventValidations

    validates :location_id, presence: true

    def location_id=(location_id)
      details['location_id'] = location_id
    end

    def location_id
      details['location_id']
    end
  end
end

class GenericEvent
  class PerIncident < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    def event_classification
      :incident
    end

    def self.inherited(child)
      child.details_attributes :supplier_personnel_number, :police_personnel_number
      child.relationship_attributes location_id: :locations
      child.eventable_types 'PersonEscortRecord'

      child.include PersonnelNumberValidations
      child.include LocationFeed
      child.include LocationValidations

      super
    end
  end
end

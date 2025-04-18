class GenericEvent
  class Medical < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    def event_classification
      :medical
    end

    def self.inherited(child)
      child.details_attributes :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :police_personnel_number, :vehicle_reg
      child.relationship_attributes location_id: :locations
      child.eventable_types 'PersonEscortRecord'

      child.include PersonnelNumberValidations
      child.include LocationFeed
      child.include LocationValidations

      child.validates :advised_at, allow_nil: true, iso_date_time: true
      child.validates :treated_at, allow_nil: true, iso_date_time: true

      super
    end
  end
end

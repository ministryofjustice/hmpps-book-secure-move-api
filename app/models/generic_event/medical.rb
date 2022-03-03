class GenericEvent
  class Medical < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    def event_classification
      :medical
    end

    def self.inherited(child)
      child.details_attributes :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :vehicle_reg
      child.relationship_attributes location_id: :locations

      child.include PersonEscortRecordEventValidations
      child.include PersonnelNumberValidations
      child.include LocationFeed
      child.include LocationValidations

      child.validates :advised_at, presence: true, iso_date_time: true
      child.validates :advised_by, presence: true
      child.validates :treated_at, allow_nil: true, iso_date_time: true

      super
    end
  end
end

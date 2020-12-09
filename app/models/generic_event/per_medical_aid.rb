class GenericEvent
  class PerMedicalAid < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :vehicle_reg

    relationship_attributes location_id: :locations

    include LocationValidations
    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations
    include LocationFeed

    validates :advised_at, presence: true, iso_date_time: true
    validates :advised_by, presence: true
    validates :treated_at, presence: true, iso_date_time: true
    validates :treated_by, presence: true

    def event_classification
      :medical
    end
  end
end

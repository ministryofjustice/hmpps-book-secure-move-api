class GenericEvent
  class PerMedicalAid < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :advised_at, :advised_by, :treated_at, :treated_by, :supplier_personnel_number, :vehicle_reg

    relationship_attributes :location_id

    include LocationValidations
    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations

    validates :advised_at, presence: true
    validates :advised_by, presence: true
    validates :treated_at, presence: true
    validates :treated_by, presence: true

    validates_each :advised_at, :treated_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
  end
end

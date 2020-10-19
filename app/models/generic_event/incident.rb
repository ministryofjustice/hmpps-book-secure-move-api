class GenericEvent
  class Incident < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    def self.inherited(child)
      child.details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at
      child.relationship_attributes :location_id
      child.eventable_types 'Move', 'Person'

      child.include LocationValidations
      child.include SupplierPersonnelNumberValidations

      child.validates :reported_at, iso_date_time: true
      super
    end
  end
end

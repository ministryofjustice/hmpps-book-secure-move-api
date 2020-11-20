class GenericEvent
  class Incident < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    def self.inherited(child)
      child.details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at, :fault_classification
      child.relationship_attributes location_id: :locations
      child.eventable_types 'Move', 'Person'
      child.enum fault_classification: {
        was_not_supplier: 'was_not_supplier',
        supplier: 'supplier',
        investigation: 'investigation',
      }

      child.include LocationValidations
      child.include SupplierPersonnelNumberValidations
      child.include LocationFeed

      child.validates :reported_at, iso_date_time: true
      child.validates :fault_classification, presence: true, inclusion: { in: child.fault_classifications }

      super
    end
  end
end

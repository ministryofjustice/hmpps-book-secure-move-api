class GenericEvent
  class PersonMoveAssault < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at
    relationship_attributes :location_id
    eventable_types 'Move', 'Person'

    include LocationValidations
    include SupplierPersonnelNumberValidations

    validates :reported_at, iso_date_time: true
  end
end

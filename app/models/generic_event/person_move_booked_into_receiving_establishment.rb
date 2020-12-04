class GenericEvent
  class PersonMoveBookedIntoReceivingEstablishment < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_number
    relationship_attributes location_id: :locations
    eventable_types 'Move', 'Person'

    include LocationValidations
    include SupplierPersonnelNumberValidations
    include LocationFeed
  end
end

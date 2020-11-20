class GenericEvent
  class PersonMoveVehicleBrokeDown < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at, :postcode
    relationship_attributes location_id: :locations
    eventable_types 'Move', 'Person'

    include LocationValidations
    include SupplierPersonnelNumberValidations
    include VehicleRegValidations
    include LocationFeed

    validates :postcode,    presence: true, postcode: true
    validates :reported_at, presence: true, iso_date_time: true
  end
end

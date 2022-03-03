class GenericEvent
  class PersonMoveVehicleBrokeDown < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at, :postcode, :location_description
    relationship_attributes location_id: :locations
    eventable_types 'Move', 'Person'

    include LocationValidations
    include PersonnelNumberValidations
    include VehicleRegValidations
    include LocationFeed

    validates :postcode, postcode: true
    validates :reported_at, presence: true, iso_date_time: true
    validates :postcode, presence: true, unless: :location_description
    validates :location_description, presence: true, unless: :postcode
  end
end

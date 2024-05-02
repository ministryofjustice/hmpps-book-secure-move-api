class GenericEvent
  class PerPropertyChange < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :vehicle_reg, :supplier_personnel_number, :police_personnel_number
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include LocationValidations
    include PersonnelNumberValidations
    include LocationFeed
  end
end
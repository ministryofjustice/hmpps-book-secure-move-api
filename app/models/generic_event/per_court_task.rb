class GenericEvent
  class PerCourtTask < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_number
    relationship_attributes location_id: :locations
    eventable_types 'PersonEscortRecord'

    include LocationValidations
    include PersonnelNumberValidations
    include LocationFeed
  end
end

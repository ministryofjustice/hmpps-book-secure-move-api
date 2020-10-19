class GenericEvent
  class PerCourtRelease < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_number
    relationship_attributes :location_id

    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations
    include LocationValidations
  end
end

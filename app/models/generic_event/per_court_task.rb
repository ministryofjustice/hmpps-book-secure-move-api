class GenericEvent
  class PerCourtTask < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_number
    relationship_attributes location_id: :locations

    include PersonEscortRecordEventValidations
    include LocationValidations
    include SupplierPersonnelNumberValidations
    include LocationFeed
  end
end

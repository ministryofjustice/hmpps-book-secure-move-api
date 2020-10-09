class GenericEvent
  class PerCourtTask < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    include PersonEscortRecordEventValidations
    include LocationValidations
    include SupplierPersonnelNumberValidations
  end
end

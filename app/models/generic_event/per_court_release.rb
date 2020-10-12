class GenericEvent
  class PerCourtRelease < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      supplier_personnel_number
    ].freeze

    include PersonEscortRecordEventValidations
    include SupplierPersonnelNumberValidations
    include LocationValidations
  end
end

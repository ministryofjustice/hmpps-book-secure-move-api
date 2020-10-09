class GenericEvent
  class PerCourtTask < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id
    DETAILS_ATTRIBUTES = %w[
      supplier_personnel_number
    ].freeze

    include PersonEscortRecordEventValidations
    include LocationValidations
    include SupplierPersonnelNumberValidations
  end
end

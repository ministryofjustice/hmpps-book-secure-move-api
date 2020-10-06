class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_reg
      supplier_personnel_number
    ].freeze

    include JourneyEventValidations
    include VehicleRegValidations

    def supplier_personnel_number
      details['supplier_personnel_number']
    end
  end
end

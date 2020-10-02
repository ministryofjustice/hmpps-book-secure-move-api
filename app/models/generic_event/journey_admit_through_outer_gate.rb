class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_reg
      supplier_personnel_id
    ].freeze

    include JourneyEventValidations
    include VehicleRegValidations

    def supplier_personnel_id
      details['supplier_personnel_id']
    end
  end
end

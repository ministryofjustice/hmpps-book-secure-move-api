class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_reg
      supplier_personnel_id
    ].freeze

    include JourneyEventValidations

    validates :vehicle_reg, presence: true

    def vehicle_reg=(vehicle_reg)
      details['vehicle_reg'] = vehicle_reg
    end

    def vehicle_reg
      details['vehicle_reg']
    end

    def supplier_personnel_id
      details['supplier_personnel_id']
    end
  end
end

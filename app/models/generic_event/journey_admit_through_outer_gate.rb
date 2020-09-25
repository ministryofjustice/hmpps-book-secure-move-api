class GenericEvent
  class JourneyAdmitThroughOuterGate < GenericEvent
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

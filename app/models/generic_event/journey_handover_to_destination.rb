class GenericEvent
  class JourneyHandoverToDestination < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      supplier_personnel_number
    ].freeze

    include JourneyEventValidations

    def supplier_personnel_number
      details['supplier_personnel_number']
    end
  end
end

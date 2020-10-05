class GenericEvent
  class JourneyHandoverToDestination < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      supplier_personnel_id
    ].freeze

    include JourneyEventValidations

    def supplier_personnel_id
      details['supplier_personnel_id']
    end
  end
end

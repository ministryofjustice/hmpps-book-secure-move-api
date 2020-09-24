class GenericEvent
  class JourneyHandoverToDestination < GenericEvent
    include JourneyEventValidations

    def supplier_personnel_id
      details['supplier_personnel_id']
    end
  end
end

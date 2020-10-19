class GenericEvent
  class JourneyHandoverToDestination < GenericEvent
    details_attributes :supplier_personnel_number

    include JourneyEventValidations
  end
end

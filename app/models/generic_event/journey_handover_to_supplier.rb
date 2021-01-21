class GenericEvent
  class JourneyHandoverToSupplier < GenericEvent
    details_attributes :supplier_personnel_number
    eventable_types 'Journey'
  end
end

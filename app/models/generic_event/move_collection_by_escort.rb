class GenericEvent
  class MoveCollectionByEscort < GenericEvent
    details_attributes :vehicle_type
    eventable_types 'Move'

    include VehicleTypeValidations
  end
end

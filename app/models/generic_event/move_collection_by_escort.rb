class GenericEvent
  class MoveCollectionByEscort < GenericEvent
    details_attributes :vehicle_type

    include MoveEventValidations
    include VehicleTypeValidations
  end
end

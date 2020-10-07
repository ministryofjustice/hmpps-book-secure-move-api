class GenericEvent
  class MoveCollectionByEscort < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_type
    ].freeze

    include MoveEventValidations
    include VehicleTypeValidations
  end
end

class GenericEvent
  class JourneyPersonLeaveVehicle < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations
  end
end

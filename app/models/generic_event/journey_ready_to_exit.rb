class GenericEvent
  class JourneyReadyToExit < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations
  end
end

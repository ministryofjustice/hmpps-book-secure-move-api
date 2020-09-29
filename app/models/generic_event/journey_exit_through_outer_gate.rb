class GenericEvent
  class JourneyExitThroughOuterGate < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations
  end
end

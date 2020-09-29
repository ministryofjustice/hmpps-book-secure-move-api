class GenericEvent
  class JourneyArriveAtOuterGate < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations
  end
end

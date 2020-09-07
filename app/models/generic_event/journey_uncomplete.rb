class GenericEvent
  class JourneyUncomplete < GenericEvent
    EVENTABLE_TYPES = %w[Journey].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.uncomplete
    end
  end
end

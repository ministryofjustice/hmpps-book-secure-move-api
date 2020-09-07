class GenericEvent
  class JourneyComplete < GenericEvent
    EVENTABLE_TYPES = %w[Journey].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.complete
    end
  end
end

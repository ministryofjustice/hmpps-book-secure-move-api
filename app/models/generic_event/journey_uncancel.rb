class GenericEvent
  class JourneyUncancel < GenericEvent
    EVENTABLE_TYPES = %w[Journey].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.uncancel
    end
  end
end

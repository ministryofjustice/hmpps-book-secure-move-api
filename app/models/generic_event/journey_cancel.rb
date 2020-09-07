class GenericEvent
  class JourneyCancel < GenericEvent
    EVENTABLE_TYPES = %w[Journey].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.cancel
    end
  end
end

class GenericEvent
  class JourneyReject < GenericEvent
    EVENTABLE_TYPES = %w[Journey].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.reject
    end
  end
end

class GenericEvent
  class JourneyLodging < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations

    validates :to_location_id, presence: true

    def to_location_id=(id)
      details['to_location_id'] = id
    end

    def to_location_id
      @to_location_id ||= details['to_location_id']
    end

    def to_location
      Location.find_by(id: to_location_id)
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = to_location.for_feed(prefix: 'to')
      end
    end

    def self.from_event(event)
      generic_event_attributes = event.generic_event_attributes.merge(
        details: {
          to_location_id: event.event_params&.dig(:relationships, :to_location, :data, :id),
        },
      )

      new(generic_event_attributes)
    end
  end
end

class GenericEvent
  class JourneyLockout < GenericEvent
    include JourneyEventValidations

    validates :from_location_id, presence: true

    def from_location_id=(id)
      details['from_location_id'] = id
    end

    def from_location_id
      @from_location_id ||= details['from_location_id']
    end

    def from_location
      Location.find_by(id: from_location_id)
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = from_location.for_feed(prefix: 'from')
      end
    end

    def self.from_event(event)
      generic_event_attributes = event.generic_event_attributes.merge(
        details: {
          from_location_id: event.event_params&.dig(:relationships, :from_location, :data, :id),
        },
      )

      new(generic_event_attributes)
    end
  end
end

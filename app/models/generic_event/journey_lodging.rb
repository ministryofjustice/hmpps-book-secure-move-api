class GenericEvent
  class JourneyLodging < GenericEvent
    include JourneyEventValidations

    validates :to_location_id, presence: true

    eventable
    event_name
    runner, trigger

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
  end
end

class GenericEvent
  class MoveRedirect < GenericEvent
    include MoveEventValidations
    validates :to_location_id, presence: true

    def to_location_id=(id)
      details['to_location_id'] = id
    end

    def to_location_id
      details['to_location_id']
    end

    def move_type
      details['move_type']
    end

    def to_location
      Location.find_by(id: to_location_id)
    end

    def trigger
      eventable.to_location = to_location
      eventable.move_type = move_type if move_type.present?
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = to_location.for_feed(prefix: 'to')
        common_feed_attributes['details']['move_type'] = move_type if move_type.present?
      end
    end

    def self.from_event(event)
      new(event.generic_event_attributes.merge(
            details: {
              to_location_id: event.event_params&.dig(:relationships, :to_location, :data, :id),
              move_type: event.event_params&.dig(:attributes, :move_type),
            },
          ))
    end
  end
end

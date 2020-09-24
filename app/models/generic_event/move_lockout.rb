class GenericEvent
  class MoveLockout < GenericEvent
    include MoveEventValidations

    enum reason: {
      unachievable_ptr_request: 'unachievable_ptr_request', # (PECS - policy only)
      no_space: 'no_space', # (PECS)
      unachievable_redirection: 'unachievable_redirection', # (PECS)
      late_sitting_court: 'late_sitting_court', # (PECS)
      unavailable_resource_vehicle_or_staff: 'unavailable_resource_vehicle_or_staff', # (supplier)
      traffic_issues: 'traffic_issues', # (supplier)
      mechanical_or_other_vehicle_failure: 'mechanical_or_other_vehicle_failure', # (supplier)
      ineffective_route_planning: 'ineffective_route_planning', # (supplier)
      other: 'other',
    }

    validates :from_location_id, presence: true
    validates :reason, inclusion: { in: reasons }, if: -> { reason }

    validates_each :authorised_at, if: -> { authorised_at.present? } do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def authorised_at=(authorised_at)
      details['authorised_at'] = authorised_at
    end

    def authorised_at
      details['authorised_at']
    end

    def authorised_by=(authorised_by)
      details['authorised_by'] = authorised_by
    end

    def authorised_by
      details['authorised_by']
    end

    def reason=(reason)
      details['reason'] = reason
    end

    def reason
      details['reason']
    end

    def from_location_id=(id)
      details['from_location_id'] = id
    end

    def from_location_id
      details['from_location_id']
    end

    def from_location
      Location.find_by(id: from_location_id)
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = from_location.for_feed(prefix: 'from')
        common_feed_attributes['details'].merge!(
          'authorised_at' => authorised_at,
          'authorised_by' => authorised_by,
          'reason' => reason,
        )
      end
    end

    def self.from_event(event)
      new(event.generic_event_attributes.merge(
            details: {
              from_location_id: event.event_params&.dig(:relationships, :from_location, :data, :id),
            },
          ))
    end
  end
end

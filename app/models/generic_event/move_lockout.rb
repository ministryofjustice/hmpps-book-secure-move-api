class GenericEvent
  class MoveLockout < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :from_location_id

    details_attributes :authorised_at, :authorised_by, :reason
    relationship_attributes :from_location_id

    include MoveEventValidations
    include AuthoriserValidations
    include LocationValidations

    enum reason: {
      unachievable_ptr_request: 'unachievable_ptr_request', # (PECS - police only)
      no_space: 'no_space', # (PECS)
      unachievable_redirection: 'unachievable_redirection', # (PECS)
      late_sitting_court: 'late_sitting_court', # (PECS)
      unavailable_resource_vehicle_or_staff: 'unavailable_resource_vehicle_or_staff', # (supplier)
      traffic_issues: 'traffic_issues', # (supplier)
      mechanical_or_other_vehicle_failure: 'mechanical_or_other_vehicle_failure', # (supplier)
      ineffective_route_planning: 'ineffective_route_planning', # (supplier)
      other: 'other',
    }

    validates :reason, inclusion: { in: reasons }, if: -> { reason }

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

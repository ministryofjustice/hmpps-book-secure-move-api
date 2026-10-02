class GenericEvent
  class MoveNotifyPremisesOfDropOffEta < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :expected_at
    relationship_attributes location_id: :locations
    eventable_types 'Move'

    include LocationFeed
    include DropOffLocationResolvable

    # NB: not using LocationValidations, since prison_recall and video_remand moves have no
    # to_location, so there may be no drop-off location to resolve
    validates_each LOCATION_ATTRIBUTE_KEY, allow_nil: true do |_record, _attr, value|
      Location.find(value)
    end
    validates :expected_at, presence: true, iso_date_time: true
  end
end

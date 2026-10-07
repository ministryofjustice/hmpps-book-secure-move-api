class GenericEvent
  class MoveNotifyPremisesOfExpectedCollectionTime < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :expected_at
    relationship_attributes location_id: :locations
    eventable_types 'Move'

    include LocationValidations
    include LocationFeed
    include PickupLocationResolvable

    validates :expected_at, presence: true
    validates :expected_at, iso_date_time: true
  end
end

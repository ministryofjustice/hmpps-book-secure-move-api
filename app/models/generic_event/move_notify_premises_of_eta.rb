# TODO: remove this event once we have migrated over to MoveNotifyPremisesOfDropOffEta + MoveNotifyPremisesOfPickupEta
class GenericEvent
  class MoveNotifyPremisesOfEta < GenericEvent
    details_attributes :expected_at
    eventable_types 'Move'

    validates :expected_at, presence: true, iso_date_time: true
  end
end

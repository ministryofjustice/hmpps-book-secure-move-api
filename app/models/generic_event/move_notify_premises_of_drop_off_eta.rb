class GenericEvent
  class MoveNotifyPremisesOfDropOffEta < GenericEvent
    details_attributes :expected_at
    eventable_types 'Move'

    validates :expected_at, presence: true, iso_date_time: true
  end
end

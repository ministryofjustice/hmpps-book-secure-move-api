class GenericEvent
  class MoveNotifyPremisesOfEta < GenericEvent
    details_attributes :expected_at

    include MoveEventValidations

    validates :expected_at, presence: true

    validates :expected_at, iso_date_time: true
  end
end

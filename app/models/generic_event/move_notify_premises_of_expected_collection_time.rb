class GenericEvent
  class MoveNotifyPremisesOfExpectedCollectionTime < GenericEvent
    details_attributes :expected_at

    include MoveEventValidations

    validates :expected_at, presence: true

    validates_each :expected_at, iso_date_time: true
  end
end

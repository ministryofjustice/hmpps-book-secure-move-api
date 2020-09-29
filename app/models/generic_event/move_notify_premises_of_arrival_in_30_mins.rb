class GenericEvent
  class MoveNotifyPremisesOfArrivalIn30Mins < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include MoveEventValidations
  end
end

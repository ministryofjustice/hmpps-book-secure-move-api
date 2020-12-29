class GenericEvent
  class MoveNotifyPremisesOfArrivalIn30Mins < GenericEvent
    eventable_types 'Move'

    def event_classification
      :notification
    end
  end
end

class GenericEvent
  class Notification < GenericEvent
    def event_classification
      :notification
    end
  end
end

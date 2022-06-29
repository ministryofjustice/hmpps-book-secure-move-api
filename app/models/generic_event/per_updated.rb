class GenericEvent
  class PerUpdated < GenericEvent
    details_attributes :responded_by, :section
    eventable_types 'PersonEscortRecord'
  end
end

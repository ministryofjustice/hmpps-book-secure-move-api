class GenericEvent
  class PerConfirmation < GenericEvent
    details_attributes :confirmed_at, :responded_by
    eventable_types 'PersonEscortRecord'

    validates :confirmed_at, presence: true

    before_create do
      self.responded_by = eventable.responded_by
    end
  end
end

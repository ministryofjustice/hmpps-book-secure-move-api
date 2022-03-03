class GenericEvent
  class PerConfirmation < GenericEvent
    details_attributes :confirmed_at
    eventable_types 'PersonEscortRecord'

    validates :confirmed_at, presence: true
  end
end

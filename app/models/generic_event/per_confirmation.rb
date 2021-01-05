class GenericEvent
  class PerConfirmation < GenericEvent
    details_attributes :confirmed_at
    include PersonEscortRecordEventValidations

    validates :confirmed_at, presence: true
  end
end

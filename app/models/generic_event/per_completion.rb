class GenericEvent
  class PerCompletion < GenericEvent
    details_attributes :completed_at, :responded_by
    eventable_types 'PersonEscortRecord'

    validates :completed_at, presence: true

    before_create do
      self.responded_by = eventable.responded_by(completed_at)
    end
  end
end

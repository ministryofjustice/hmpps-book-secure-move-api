class GenericEvent
  class MoveCollectionByEscort < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      vehicle_type
    ].freeze

    include MoveEventValidations

    enum vehicle_type: {
      cellular: 'cellular',
      mpv: 'mpv',
      other: 'other',
    }

    validates :vehicle_type, inclusion: { in: vehicle_types }

    def vehicle_type=(vehicle_type)
      details['vehicle_type'] = vehicle_type
    end

    def vehicle_type
      details['vehicle_type']
    end
  end
end

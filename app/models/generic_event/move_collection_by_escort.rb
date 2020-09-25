class GenericEvent
  class MoveCollectionByEscort < GenericEvent
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

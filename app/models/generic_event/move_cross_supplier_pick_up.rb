class GenericEvent
  class MoveCrossSupplierPickUp < GenericEvent
    details_attributes :previous_move_reference

    # relationship_attributes previous_move_id: :moves
    # relationship_attributes previous_move_reference: :moves

    eventable_types 'Move'

    # validates_each :previous_move_id do |_record, _attr, value|
    #   Move.find(value)
    # end

    def previous_move

    end

    def previous_move_reference

    end

    def previous_move_reference=

    end
  end
end

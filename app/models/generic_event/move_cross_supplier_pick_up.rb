class GenericEvent
  class MoveCrossSupplierPickUp < GenericEvent
    relationship_attributes previous_move_id: :moves
    eventable_types 'Move'

    validates_each :previous_move_id do |_record, _attr, value|
      Move.find(value)
    end
  end
end

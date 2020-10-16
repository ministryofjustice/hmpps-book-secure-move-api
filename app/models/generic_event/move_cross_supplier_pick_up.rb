class GenericEvent
  class MoveCrossSupplierPickUp < GenericEvent
    relationship_attributes :previous_move_id
    eventable_types 'Move'

    validates_each :previous_move_id do |_record, _attr, value|
      Move.find(value)
    end

    include MoveEventValidations
  end
end

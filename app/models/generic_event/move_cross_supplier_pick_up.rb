class GenericEvent
  class MoveCrossSupplierPickUp < GenericEvent
    details_attributes :previous_move_reference
    relationship_attributes previous_move_id: :moves
    eventable_types 'Move'

    validates_each :previous_move_id do |_record, _attr, value|
      Move.find(value)
    end

    before_validation :set_move_id_from_reference

    # NB previous_move_reference is not a persisted attribute - it maps to previous_move_id
    def previous_move_reference
      previous_move&.reference
    end

    def set_move_id_from_reference(reference = details.delete('previous_move_reference'))
      if reference.present?
        details['previous_move_id'] = Move.find_by!(reference:).id
      end
    end

    alias_method :previous_move_reference=, :set_move_id_from_reference
  end
end

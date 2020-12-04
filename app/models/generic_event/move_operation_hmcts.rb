class GenericEvent
  class MoveOperationHmcts < GenericEvent
    details_attributes :authorised_at, :authorised_by, :court_cell_number
    eventable_types 'Move'

    include AuthoriserValidations
    include CourtCellValidations
  end
end

class GenericEvent
  class MoveOperationHmcts < GenericEvent
    details_attributes :authorised_at, :authorised_by, :court_cell_number

    include MoveEventValidations
    include AuthoriserValidations
    include CourtCellValidations
  end
end

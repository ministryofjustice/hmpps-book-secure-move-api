class GenericEvent
  class MoveOperationHmcts < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      authorised_at
      authorised_by
      court_cell_number
    ].freeze

    include MoveEventValidations
    include AuthoriserValidations
    include CourtCellValidations
  end
end

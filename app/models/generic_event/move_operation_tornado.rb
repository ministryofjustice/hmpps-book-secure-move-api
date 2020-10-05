class GenericEvent
  class MoveOperationTornado < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      authorised_at
      authorised_by
    ].freeze

    include MoveEventValidations
    include AuthoriserValidations
  end
end

class GenericEvent
  class MoveOperationTornado < GenericEvent
    details_attributes :authorised_at, :authorised_by

    include MoveEventValidations
    include AuthoriserValidations
  end
end

class GenericEvent
  class MoveOperationTornado < GenericEvent
    include MoveEventValidations
    include AuthoriserValidations
  end
end

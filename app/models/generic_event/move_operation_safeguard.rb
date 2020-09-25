class GenericEvent
  class MoveOperationSafeguard < GenericEvent
    include MoveEventValidations
    include AuthoriserValidations
  end
end

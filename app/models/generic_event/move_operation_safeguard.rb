class GenericEvent
  class MoveOperationSafeguard < GenericEvent
    details_attributes :authorised_at, :authorised_by

    include MoveEventValidations
    include AuthoriserValidations
  end
end

class GenericEvent
  class MoveOperationSafeguard < GenericEvent
    details_attributes :authorised_at, :authorised_by
    eventable_types 'Move'

    include AuthoriserValidations
  end
end

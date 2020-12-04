class GenericEvent
  class MoveOperationTornado < GenericEvent
    details_attributes :authorised_at, :authorised_by
    eventable_types 'Move'

    include AuthoriserValidations
  end
end

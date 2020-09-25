RSpec.describe GenericEvent::MoveOperationSafeguard do
  subject(:generic_event) { build(:event_move_operation_safeguard) }

  it_behaves_like 'a move event'
  it_behaves_like 'an authorised event'
end

require 'rails_helper'

RSpec.describe GenericEvent::MoveOperationTornado do
  subject(:generic_event) { build(:event_move_operation_tornado) }

  it_behaves_like 'an event with details', :authorised_at, :authorised_by
  it_behaves_like 'a move event'
  it_behaves_like 'an authorised event'
end

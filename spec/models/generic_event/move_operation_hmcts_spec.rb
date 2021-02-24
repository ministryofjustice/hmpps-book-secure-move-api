require 'rails_helper'

RSpec.describe GenericEvent::MoveOperationHmcts do
  subject(:generic_event) { build(:event_move_operation_hmcts) }

  it_behaves_like 'an event with details', :authorised_at, :authorised_by, :court_cell_number
  it_behaves_like 'a move event'
  it_behaves_like 'an authorised event'
  it_behaves_like 'a court cell event'
end

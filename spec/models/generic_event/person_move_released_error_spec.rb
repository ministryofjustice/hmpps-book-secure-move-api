RSpec.describe GenericEvent::PersonMoveReleasedError do
  subject(:generic_event) { build(:event_person_move_released_error) }

  it_behaves_like 'an event about an incident'
end

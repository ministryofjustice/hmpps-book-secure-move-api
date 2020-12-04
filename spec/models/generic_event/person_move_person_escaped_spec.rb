RSpec.describe GenericEvent::PersonMovePersonEscaped do
  subject(:generic_event) { build(:event_person_move_person_escaped) }

  it_behaves_like 'an event about an incident'
end

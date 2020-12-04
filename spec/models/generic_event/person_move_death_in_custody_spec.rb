RSpec.describe GenericEvent::PersonMoveDeathInCustody do
  subject(:generic_event) { build(:event_person_move_death_in_custody) }

  it_behaves_like 'an event about an incident'
end

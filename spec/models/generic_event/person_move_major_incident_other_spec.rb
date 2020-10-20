RSpec.describe GenericEvent::PersonMoveMajorIncidentOther do
  subject(:generic_event) { build(:event_person_move_major_incident_other) }

  it_behaves_like 'an event about an incident'
end

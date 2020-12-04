RSpec.describe GenericEvent::PersonMoveRoadTrafficAccident do
  subject(:generic_event) { build(:event_person_move_road_traffic_accident) }

  it_behaves_like 'an event about an incident'
  it_behaves_like 'an event that specifies a vehicle registration'
end

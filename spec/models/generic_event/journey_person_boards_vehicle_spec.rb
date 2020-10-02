RSpec.describe GenericEvent::JourneyPersonBoardsVehicle do
  subject(:generic_event) { build(:event_journey_person_boards_vehicle) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event that specifies a vehicle type' 
  it_behaves_like 'an event that specifies a vehicle registration' 
end

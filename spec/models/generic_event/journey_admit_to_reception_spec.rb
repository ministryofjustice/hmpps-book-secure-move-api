RSpec.describe GenericEvent::JourneyAdmitToReception do
  subject(:generic_event) { build(:event_journey_admit_to_reception) }

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

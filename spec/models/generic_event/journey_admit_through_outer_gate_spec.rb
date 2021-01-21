RSpec.describe GenericEvent::JourneyAdmitThroughOuterGate do
  subject(:generic_event) { build(:event_journey_admit_through_outer_gate) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with details', :vehicle_reg, :supplier_personnel_number
  it_behaves_like 'an event that specifies a vehicle registration'
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id
end

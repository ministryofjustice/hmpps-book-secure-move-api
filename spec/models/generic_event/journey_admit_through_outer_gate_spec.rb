RSpec.describe GenericEvent::JourneyAdmitThroughOuterGate do
  subject(:generic_event) { build(:event_journey_admit_through_outer_gate) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with details', :vehicle_reg, :supplier_personnel_number
  it_behaves_like 'an event that specifies a vehicle registration'
end

RSpec.describe GenericEvent::JourneyAdmitThroughOuterGate do
  subject(:generic_event) { build(:event_journey_admit_through_outer_gate) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
  it { is_expected.to validate_presence_of(:vehicle_reg) }
end

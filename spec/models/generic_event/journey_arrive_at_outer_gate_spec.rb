RSpec.describe GenericEvent::JourneyArriveAtOuterGate do
  subject(:generic_event) { build(:event_journey_arrive_at_outer_gate) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

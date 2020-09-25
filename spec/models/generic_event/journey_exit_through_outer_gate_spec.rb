RSpec.describe GenericEvent::JourneyExitThroughOuterGate do
  subject(:generic_event) { build(:event_journey_exit_through_outer_gate) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

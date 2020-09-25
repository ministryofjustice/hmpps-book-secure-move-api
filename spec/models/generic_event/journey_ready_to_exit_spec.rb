RSpec.describe GenericEvent::JourneyReadyToExit do
  subject(:generic_event) { build(:event_journey_ready_to_exit) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

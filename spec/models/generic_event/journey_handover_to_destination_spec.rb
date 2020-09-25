RSpec.describe GenericEvent::JourneyHandoverToDestination do
  subject(:generic_event) { build(:event_journey_handover_to_destination) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

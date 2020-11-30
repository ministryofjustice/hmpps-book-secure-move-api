RSpec.describe GenericEvent::JourneyUpdate do
  subject(:generic_event) { build(:event_journey_update) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

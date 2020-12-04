RSpec.describe GenericEvent::JourneyHandoverToDestination do
  subject(:generic_event) { build(:event_journey_handover_to_destination) }

  it_behaves_like 'an event with details', :supplier_personnel_number

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

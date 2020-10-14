RSpec.describe GenericEvent::PerCourtReadyInCustody do
  subject(:generic_event) { build(:event_per_court_ready_in_custody) }

  it_behaves_like 'an event with relationships', :location_id
  it_behaves_like 'an event requiring a location', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end

RSpec.describe GenericEvent::PerCourtRelease do
  subject(:generic_event) { build(:event_per_court_release) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
end

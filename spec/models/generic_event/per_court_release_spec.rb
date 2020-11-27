RSpec.describe GenericEvent::PerCourtRelease do
  subject(:generic_event) { build(:event_per_court_release) }

  it_behaves_like 'an event with details', :supplier_personnel_number
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a supplier personnel number'
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end

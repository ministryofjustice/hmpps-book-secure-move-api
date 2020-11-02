RSpec.describe GenericEvent::PerCourtTakeToSeeVisitors do
  subject(:generic_event) { build(:event_per_court_take_to_see_visitors) }

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end

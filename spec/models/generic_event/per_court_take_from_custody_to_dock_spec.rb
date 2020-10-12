RSpec.describe GenericEvent::PerCourtTakeFromCustodyToDock do
  subject(:generic_event) { build(:event_per_court_take_from_custody_to_dock) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
end

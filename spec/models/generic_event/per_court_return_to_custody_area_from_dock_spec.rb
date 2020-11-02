RSpec.describe GenericEvent::PerCourtReturnToCustodyAreaFromDock do
  subject(:generic_event) { build(:event_per_court_return_to_custody_area_from_dock) }

  let(:subtypes) do
    %w[
      court_cell_number
    ]
  end

  it_behaves_like 'an event with details', :court_cell_number
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
end

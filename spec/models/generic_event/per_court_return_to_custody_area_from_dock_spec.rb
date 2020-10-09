RSpec.describe GenericEvent::PerCourtReturnToCustodyAreaFromDock do
  subject(:generic_event) { build(:event_per_court_return_to_custody_area_from_dock) }

  let(:subtypes) do
    %w[
      court_cell_number
    ]
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
end

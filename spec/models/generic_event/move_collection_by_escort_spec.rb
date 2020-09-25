RSpec.describe GenericEvent::MoveCollectionByEscort do
  subject(:generic_event) { build(:event_move_collection_by_escort) }

  let(:vehicle_types) do
    %w[
      cellular
      mpv
      other
    ]
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_inclusion_of(:vehicle_type).in_array(vehicle_types) }
end

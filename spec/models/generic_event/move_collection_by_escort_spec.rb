RSpec.describe GenericEvent::MoveCollectionByEscort do
  subject(:generic_event) { build(:event_move_collection_by_escort) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }

  it_behaves_like 'an event that specifies a vehicle type'
end

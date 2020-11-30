RSpec.describe GenericEvent::MoveRequested do
  subject(:generic_event) { build(:event_move_requested) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
end

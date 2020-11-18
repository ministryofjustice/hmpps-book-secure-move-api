RSpec.describe GenericEvent::MoveProposed do
  subject(:generic_event) { build(:event_move_proposed) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
end

RSpec.describe GenericEvent::MoveLodgingEnd do
  subject(:generic_event) { build(:event_move_lodging_end) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_presence_of(:location_id) }
end

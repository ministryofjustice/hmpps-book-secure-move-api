RSpec.describe GenericEvent::MoveNotifyPremisesOfArrivalIn30Mins do
  subject(:generic_event) { build(:event_move_notify_premises_of_arrival_in_30_mins) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
end

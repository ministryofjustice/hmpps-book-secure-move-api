require 'rails_helper'

RSpec.describe GenericEvent::MoveNotifyPremisesOfArrivalIn30Mins do
  subject(:generic_event) { build(:event_move_notify_premises_of_arrival_in30_mins) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }

  it_behaves_like 'an event about a notification', :event_move_notify_premises_of_arrival_in30_mins
end

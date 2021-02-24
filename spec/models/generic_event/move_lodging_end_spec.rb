require 'rails_helper'

RSpec.describe GenericEvent::MoveLodgingEnd do
  subject(:generic_event) { build(:event_move_lodging_end) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
end

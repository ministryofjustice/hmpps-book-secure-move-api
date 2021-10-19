require 'rails_helper'

RSpec.describe GenericEvent::JourneyReadyToExit do
  subject(:generic_event) { build(:event_journey_ready_to_exit) }

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id
  it_behaves_like 'an event that will require a vehicle registration'

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

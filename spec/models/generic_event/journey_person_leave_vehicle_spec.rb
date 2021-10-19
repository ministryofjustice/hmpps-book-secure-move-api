require 'rails_helper'

RSpec.describe GenericEvent::JourneyPersonLeaveVehicle do
  subject(:generic_event) { build(:event_journey_person_leave_vehicle) }

  it_behaves_like 'an event that will require a vehicle registration'

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

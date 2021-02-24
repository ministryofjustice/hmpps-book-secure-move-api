require 'rails_helper'

RSpec.describe GenericEvent::JourneyPersonLeaveVehicle do
  subject(:generic_event) { build(:event_journey_person_leave_vehicle) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }
end

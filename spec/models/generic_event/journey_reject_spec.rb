require 'rails_helper'

RSpec.describe GenericEvent::JourneyReject do
  subject(:generic_event) { build(:event_journey_reject) }

  it_behaves_like 'a journey event', :reject do
    subject(:generic_event) { build(:event_journey_reject) }
  end
end

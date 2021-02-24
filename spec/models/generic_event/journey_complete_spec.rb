require 'rails_helper'

RSpec.describe GenericEvent::JourneyComplete do
  subject(:generic_event) { build(:event_journey_complete) }

  it_behaves_like 'a journey event', :complete do
    subject(:generic_event) { build(:event_journey_complete) }
  end
end

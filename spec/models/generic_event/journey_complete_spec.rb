require 'rails_helper'

RSpec.describe GenericEvent::JourneyComplete do
  subject(:generic_event) { build(:event_journey_complete) }

  it_behaves_like 'a journey event', :complete do
    subject(:generic_event) { build(:event_journey_complete) }
  end

  it_behaves_like 'an event that must not occur before', 'GenericEvent::JourneyStart'
  it_behaves_like 'an event that must not occur after', 'GenericEvent::MoveComplete'
end

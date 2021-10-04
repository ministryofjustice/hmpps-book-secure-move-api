require 'rails_helper'

RSpec.describe GenericEvent::JourneyStart do
  subject(:generic_event) { build(:event_journey_start) }

  it_behaves_like 'a journey event', :start do
    subject(:generic_event) { build(:event_journey_start) }
  end

  it_behaves_like 'an event that must not occur after', 'GenericEvent::JourneyComplete'
end

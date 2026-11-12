require 'rails_helper'

RSpec.describe GenericEvent::JourneyUncomplete do
  subject(:generic_event) { build(:event_journey_uncomplete) }

  it_behaves_like 'a journey event', :uncomplete do
    subject(:generic_event) { build(:event_journey_uncomplete) }
  end

  it_behaves_like 'an event that requires a state transition', :uncomplete, %w[completed]
end

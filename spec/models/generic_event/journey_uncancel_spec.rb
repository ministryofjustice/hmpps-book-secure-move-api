require 'rails_helper'

RSpec.describe GenericEvent::JourneyUncancel do
  subject(:generic_event) { build(:event_journey_uncancel) }

  it_behaves_like 'a journey event', :uncancel do
    subject(:generic_event) { build(:event_journey_uncancel) }
  end

  it_behaves_like 'an event that requires a state transition', :uncancel, %w[cancelled]
end

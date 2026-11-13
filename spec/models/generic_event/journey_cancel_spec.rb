require 'rails_helper'

RSpec.describe GenericEvent::JourneyCancel do
  subject(:generic_event) { build(:event_journey_cancel) }

  it_behaves_like 'a journey event', :cancel do
    subject(:generic_event) { build(:event_journey_cancel) }
  end

  it_behaves_like 'an event that requires a state transition', :cancel, %w[in_progress]
end

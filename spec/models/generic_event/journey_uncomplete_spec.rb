RSpec.describe GenericEvent::JourneyUncomplete do
  subject(:generic_event) { build(:event_journey_uncomplete) }

  it_behaves_like 'a journey event', :uncomplete do
    subject(:generic_event) { build(:event_journey_uncomplete) }
  end
end

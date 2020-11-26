RSpec.describe GenericEvent::JourneyStart do
  subject(:generic_event) { build(:event_journey_start) }

  it_behaves_like 'a journey event', :start do
    subject(:generic_event) { build(:event_journey_start) }
  end
end

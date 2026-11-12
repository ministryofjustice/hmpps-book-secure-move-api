require 'rails_helper'

RSpec.describe GenericEvent::JourneyUncomplete do
  subject(:generic_event) { build(:event_journey_uncomplete) }

  it_behaves_like 'a journey event', :uncomplete do
    subject(:generic_event) { build(:event_journey_uncomplete) }
  end

  it_behaves_like 'an event that requires a state transition', :uncomplete, %w[completed]

  describe 'backdated reversal validation' do
    let(:journey) { create(:journey, :completed) }

    it 'rejects an uncomplete event earlier than the completion it reverses' do
      create(:event_journey_complete, eventable: journey, occurred_at: Time.zone.local(2021, 1, 2), recorded_at: Time.zone.local(2021, 1, 2), skip_state_transition_validation: true)
      generic_event = build(:event_journey_uncomplete, eventable: journey, occurred_at: Time.zone.local(2021, 1, 1), recorded_at: Time.zone.local(2021, 1, 1), skip_state_transition_validation: false)

      expect(generic_event).not_to be_valid
      expect(generic_event.errors[:occurred_at]).to include("cannot journey_uncomplete after journey_complete at 2021-01-02T00:00:00+00:00")
    end

    it 'allows an uncomplete event after the completion it reverses' do
      create(:event_journey_complete, eventable: journey, occurred_at: Time.zone.local(2021, 1, 2), recorded_at: Time.zone.local(2021, 1, 2), skip_state_transition_validation: true)
      generic_event = build(:event_journey_uncomplete, eventable: journey, occurred_at: Time.zone.local(2021, 1, 3), recorded_at: Time.zone.local(2021, 1, 3), skip_state_transition_validation: false)

      expect(generic_event).to be_valid
    end
  end
end

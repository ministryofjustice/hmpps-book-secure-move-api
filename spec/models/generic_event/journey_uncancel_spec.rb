require 'rails_helper'

RSpec.describe GenericEvent::JourneyUncancel do
  subject(:generic_event) { build(:event_journey_uncancel) }

  it_behaves_like 'a journey event', :uncancel do
    subject(:generic_event) { build(:event_journey_uncancel) }
  end

  it_behaves_like 'an event that requires a state transition', :uncancel, %w[cancelled]

  describe 'backdated reversal validation' do
    let(:journey) { create(:journey, :cancelled) }

    it 'rejects an uncancel event earlier than the cancellation it reverses' do
      create(:event_journey_cancel, eventable: journey, occurred_at: Time.zone.local(2021, 1, 2), recorded_at: Time.zone.local(2021, 1, 2), skip_state_transition_validation: true)
      generic_event = build(:event_journey_uncancel, eventable: journey, occurred_at: Time.zone.local(2021, 1, 1), recorded_at: Time.zone.local(2021, 1, 1), skip_state_transition_validation: false)

      expect(generic_event).not_to be_valid
      expect(generic_event.errors[:occurred_at]).to include('cannot journey_uncancel after journey_cancel at 2021-01-02T00:00:00+00:00')
    end

    it 'allows an uncancel event after the cancellation it reverses' do
      create(:event_journey_cancel, eventable: journey, occurred_at: Time.zone.local(2021, 1, 2), recorded_at: Time.zone.local(2021, 1, 2), skip_state_transition_validation: true)
      generic_event = build(:event_journey_uncancel, eventable: journey, occurred_at: Time.zone.local(2021, 1, 3), recorded_at: Time.zone.local(2021, 1, 3), skip_state_transition_validation: false)

      expect(generic_event).to be_valid
    end
  end
end

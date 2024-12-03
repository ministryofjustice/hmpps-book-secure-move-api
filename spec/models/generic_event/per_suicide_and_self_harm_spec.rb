require 'rails_helper'

RSpec.describe GenericEvent::PerSuicideAndSelfHarm do
  let(:per_suicide_and_self_harm_event) { build(:event_per_suicide_and_self_harm) }

  it_behaves_like 'an event with details', :concerns, :history, :method,
                  :source, :source_summary, :source_observations,
                  :safety_actions, :observation_level, :comments,
                  :reporting_officer, :reporting_officer_signed_at,
                  :reception_officer, :reception_officer_signed_at

  it_behaves_like 'an event with eventable types', 'PersonEscortRecord'

  describe '#event_classification' do
    subject(:event_classification) { per_suicide_and_self_harm_event.event_classification }

    it { is_expected.to eq(:medical) }
  end
end

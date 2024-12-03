require 'rails_helper'

RSpec.describe GenericEvent::PerSuicideAndSelfHarm do
  let(:per_suicide_and_self_harm_event) { build(:event_per_suicide_and_self_harm) }

  it_behaves_like 'an event with details', :concern_intent, :concern_reaction, :concern_attempt, :concern_someone,
                  :concern_pre_sentence, :concern_behavioural, :concern_other, :method_ligature,
                  :method_cutting, :method_overdose, :method_other, :method_unknown, :share_cell,
                  :conversation, :acct_plan, :referred_medical, :other_support, :other_actions_taken,
                  :no_actions_taken, :history, :source, :source_summary, :source_observations,
                  :safety_actions, :observation_level, :comments, :reporting_officer,
                  :reporting_officer_signed_at, :reception_officer, :reception_officer_signed_at

  it_behaves_like 'an event with eventable types', 'PersonEscortRecord'

  describe '#event_classification' do
    subject(:event_classification) { per_suicide_and_self_harm_event.event_classification }

    it { is_expected.to eq(:suicide_and_self_harm) }
  end
end

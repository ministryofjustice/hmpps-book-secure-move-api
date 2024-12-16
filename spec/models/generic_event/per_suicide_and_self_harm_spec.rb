require 'rails_helper'

RSpec.describe GenericEvent::PerSuicideAndSelfHarm do
  subject(:generic_event) { build(:event_per_suicide_and_self_harm) }

  it_behaves_like 'an event with details', :indication_of_self_harm_or_suicide,
                  :nature_of_self_harm,
                  :history_of_self_harm,
                  :history_of_self_harm_recency,
                  :history_of_self_harm_method,
                  :history_of_self_harm_details,
                  :actions_of_self_harm_undertaken,
                  :observation_level,
                  :comments,
                  :reporting_officer,
                  :reporting_officer_signed_at,
                  :reception_officer,
                  :reception_officer_signed_at,
                  :supplier_personnel_number,
                  :police_personnel_number

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'PersonEscortRecord'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_presence_of(:supplier_personnel_number) }

  describe '#event_classification' do
    subject(:event_classification) { generic_event.event_classification }

    it { expect(event_classification).to eq(:suicide_and_self_harm) }
  end
end

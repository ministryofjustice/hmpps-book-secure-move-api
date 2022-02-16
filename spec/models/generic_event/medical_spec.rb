require 'rails_helper'

RSpec.describe GenericEvent::Medical, type: :model do
  let(:event) { described_class.new }

  describe '#event_type' do
    subject(:event_type) { event.event_type }

    it { is_expected.to eq('Medical') }
  end

  describe '#event_classification' do
    subject(:event_classification) { event.event_classification }

    it { is_expected.to eq(:medical) }

    context 'when event has nil classification' do
      let(:event) { create(:event_per_medical_aid, classification: nil) }

      it { is_expected.to eq(:medical) }
    end
  end
end

require 'rails_helper'

RSpec.describe GenericEvent::Incident, type: :model do
  let(:event) { described_class.new }

  describe '#event_type' do
    subject(:event_type) { event.event_type }

    it { is_expected.to eq('Incident') }
  end

  describe '#event_classification' do
    subject(:event_classification) { event.event_classification }

    it { is_expected.to eq(:incident) }

    context 'when event has nil classification' do
      let(:event) { create(:event_person_move_assault, classification: nil) }

      it { is_expected.to eq(:incident) }
    end

    describe 'when a supplier_id is nil' do
      context 'when we allow fault_classification to be nil' do
        let(:event) { create(:event_person_move_used_force, supplier_id: nil, fault_classification: nil) }

        it { is_expected.to eq(:incident) }
      end
    end
  end
end

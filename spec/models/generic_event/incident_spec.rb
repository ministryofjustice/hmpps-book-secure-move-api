require 'rails_helper'

RSpec.describe GenericEvent::Incident, type: :model do
  describe '#event_type' do
    it 'removes GenericEvent namespace when type is present' do
      event = described_class.new

      expect(event.event_type).to eq 'Incident'
    end
  end

  describe '#event_classification' do
    it 'returns :incident' do
      event = described_class.new

      expect(event.event_classification).to eq :incident
    end

    it 'is automatically assigned on creation' do
      event = create(:event_person_move_assault, classification: nil)

      expect(event.classification).to eq 'incident'
    end
  end
end

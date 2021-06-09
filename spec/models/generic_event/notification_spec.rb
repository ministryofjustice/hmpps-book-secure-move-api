require 'rails_helper'

RSpec.describe GenericEvent::Notification, type: :model do
  describe '#event_type' do
    it 'removes GenericEvent namespace when type is present' do
      event = described_class.new

      expect(event.event_type).to eq 'Notification'
    end
  end

  describe '#event_classification' do
    it 'returns :notification' do
      event = described_class.new

      expect(event.event_classification).to eq :notification
    end

    it 'is automatically assigned on creation' do
      # no real events currently have a notification classification, so use a fake one for now
      event = create(:generic_event_notification, classification: nil)

      expect(event.classification).to eq 'notification'
    end
  end
end

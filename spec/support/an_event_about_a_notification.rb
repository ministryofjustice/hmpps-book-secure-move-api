RSpec.shared_examples 'an event about a notification' do |event_type|
  describe '#event_classification' do
    it 'returns :notification' do
      event = described_class.new

      expect(event.event_classification).to eq :notification
    end

    it 'is automatically assigned on creation' do
      event = create(event_type, classification: nil)

      expect(event.classification).to eq 'notification'
    end
  end
end

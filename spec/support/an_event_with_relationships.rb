RSpec.shared_examples 'an event with relationships' do |attributes|
  describe '.relationship_attributes' do
    it 'sets the correct attributes' do
      expect(described_class.relationship_attributes).to eq(attributes)
    end
  end
end

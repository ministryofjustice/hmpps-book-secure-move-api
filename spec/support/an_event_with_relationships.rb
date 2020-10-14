RSpec.shared_examples 'an event with relationships' do |*attributes|
  describe '.relationship_attributes' do
    it 'sets the correct attributes' do
      expect(described_class.relationship_attributes).to contain_exactly(*attributes)
    end
  end
end

RSpec.shared_examples 'an event with details' do |*attributes|
  describe '.details_attributes' do
    it 'sets the correct attributes' do
      expect(described_class.details_attributes).to contain_exactly(*attributes)
    end
  end
end

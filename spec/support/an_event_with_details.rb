RSpec.shared_examples 'an event with details' do |*attributes|
  describe '.details_attributes' do
    it 'sets the correct attributes' do
      expect(described_class.details_attributes).to match_array(attributes)
    end
  end
end

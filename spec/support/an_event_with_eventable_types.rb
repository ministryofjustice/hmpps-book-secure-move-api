RSpec.shared_examples 'an event with eventable types' do |*types|
  describe '.eventable_types' do
    it 'sets the correct types' do
      expect(described_class.eventable_types).to contain_exactly(*types)
    end
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(types) }
end

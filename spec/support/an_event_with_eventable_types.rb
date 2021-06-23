RSpec.shared_examples 'an event with eventable types' do |*types|
  describe '.eventable_types' do
    it 'sets the correct types' do
      expect(described_class.eventable_types).to contain_exactly(*types)
    end
  end

  # NB: the shoulda matcher validate_inclusion_of mutates the subject during the test; so use an unsaved subject
  # (build vs create) to avoid low-level "wrong constant name shoulda-matchers test string" rspec problems
  it { expect(subject).to validate_inclusion_of(:eventable_type).in_array(types) }
end

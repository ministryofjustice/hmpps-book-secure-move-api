RSpec.shared_examples 'a journey event' do |transition|
  it 'validates eventable_type' do
    expect(generic_event).to validate_inclusion_of(:eventable_type).in_array(%w[Journey])
  end

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it "attempts to call the `Journey` with #{transition}" do
      allow(generic_event.eventable).to receive(transition)

      generic_event.trigger

      expect(generic_event.eventable).to have_received(transition)
    end
  end
end

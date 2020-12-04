RSpec.shared_examples 'a journey event' do |transition|
  it_behaves_like 'an event with eventable types', 'Journey'

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

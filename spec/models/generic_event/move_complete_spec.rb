RSpec.describe GenericEvent::MoveComplete do
  subject(:generic_event) { build(:event_move_complete) }

  it_behaves_like 'a move event'

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to booked' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('requested').to('completed')
    end
  end
end

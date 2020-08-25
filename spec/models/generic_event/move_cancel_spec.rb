RSpec.describe GenericEvent::MoveCancel do
  subject(:generic_event) { build(:event_move_cancel) }

  it 'validates cancellation_reason' do
    expect(generic_event).to validate_inclusion_of(:cancellation_reason).in_array(Move::CANCELLATION_REASONS)
  end

  it 'validates eventable_type' do
    expect(generic_event).to validate_inclusion_of(:eventable_type).in_array(%w[Move])
  end

  describe '#cancellation_reason' do
    it 'returns the cancellation_reason from the details' do
      expect(generic_event.cancellation_reason).to eq(generic_event.details['cancellation_reason'])
    end
  end

  describe '#cancellation_reason_comment' do
    it 'returns the cancellation_reason_comment from the details' do
      expect(generic_event.cancellation_reason_comment).to eq(generic_event.details['cancellation_reason_comment'])
    end
  end

  describe '#trigger' do
    before do
      allow(Allocations::RemoveFromNomis).to receive(:call)
    end

    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to cancelled' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('requested').to('cancelled')
    end

    it 'sets the eventable `cancellation_reason`' do
      expect { generic_event.trigger }.to change { generic_event.eventable.cancellation_reason }.from(nil).to('made_in_error')
    end

    it 'sets the eventable `cancellation_reason_comment`' do
      expect { generic_event.trigger }.to change { generic_event.eventable.cancellation_reason_comment }.from(nil).to('It was a mistake')
    end

    it 'calls the Allocations::RemoveFromNomis service with the eventable' do
      generic_event.trigger

      expect(Allocations::RemoveFromNomis).to have_received(:call).with(generic_event.eventable)
    end
  end
end

RSpec.describe GenericEvent::MoveApprove do
  subject(:generic_event) { build(:event_move_approve, eventable: eventable) }

  let(:eventable) { build(:move, :proposed) }

  it_behaves_like 'a move event' do
    subject(:generic_event) { build(:event_move_approve) }
  end

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger

      expect(generic_event.eventable).not_to be_persisted
    end

    rub
    it 'sets the eventable `status` to requested' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('proposed').to('requested')
    end

    it 'sets the correct date' do
      expect { generic_event.trigger }.to change { generic_event.eventable.date }.from(eventable.date).to(Date.parse(generic_event.date))
    end

    context 'when the PMU wants the move to be created in Nomis' do
      before do
        allow(Allocations::CreateInNomis).to receive(:call)
      end

      it 'calls the create in Nomis service' do
        generic_event.details[:create_in_nomis] = true

        generic_event.trigger

        expect(Allocations::CreateInNomis).to have_received(:call).with(eventable)
      end

      context 'when the PMU does NOT want the move to be created in Nomis' do
        it 'does NOT call the create in Nomis service' do
          generic_event.details[:create_in_nomis] = false

          generic_event.trigger

          expect(Allocations::CreateInNomis).not_to have_received(:call)
        end
      end
    end
  end
end

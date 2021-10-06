require 'rails_helper'

RSpec.describe GenericEvent::MoveStart do
  subject(:generic_event) { build(:event_move_start, eventable: create(:move, move_status)) }

  let(:move) { generic_event.eventable }

  shared_examples 'the move changes but is not saved' do
    it do
      expect { generic_event.trigger }.to change(move, :changed?)
    end
  end

  shared_examples 'the move status does not change' do
    it do
      expect { generic_event.trigger }.not_to change(move, :status)
    end
  end

  shared_examples_for 'the move status changes to in_transit' do
    it do
      expect { generic_event.trigger }.to change(move, :status).from('booked').to('in_transit')
    end
  end

  shared_examples_for 'the PER status does not change' do
    it do
      expect { generic_event.trigger }.not_to change(person_escort_record, :status).from(person_escort_record_status)
    end
  end

  shared_examples_for 'the PER status changes to confirmed' do
    it do
      expect { generic_event.trigger }.to change(person_escort_record, :status).from(person_escort_record_status).to('confirmed')
    end
  end

  shared_examples_for 'a GenericEvent::PerConfirmation event is created' do
    it do
      expect { generic_event.trigger }.to change { person_escort_record.generic_events.where(type: 'GenericEvent::PerConfirmation').count }.from(0).to(1)
    end
  end

  shared_examples_for 'a GenericEvent::PerConfirmation event is not created' do
    it do
      expect { generic_event.trigger }.not_to change { person_escort_record.generic_events.where(type: 'GenericEvent::PerConfirmation').exists? }.from(false)
    end
  end

  shared_examples_for 'a per confirmation webhook is sent' do
    before { allow(Notifier).to receive(:prepare_notifications) }

    it do
      generic_event.trigger
      expect(Notifier).to have_received(:prepare_notifications).with(topic: person_escort_record, action_name: 'confirm_person_escort_record')
    end
  end

  shared_examples_for 'a per confirmation webhook is not sent' do
    before { allow(Notifier).to receive(:prepare_notifications) }

    it do
      generic_event.trigger
      expect(Notifier).not_to have_received(:prepare_notifications).with(topic: person_escort_record, action_name: 'confirm_person_escort_record')
    end
  end

  context 'when the move status is requested' do
    let(:move_status) { :requested }

    it_behaves_like 'the move status does not change'
    it_behaves_like 'an event that must not occur after', 'GenericEvent::MoveComplete', 'GenericEvent::JourneyStart'
  end

  context 'when the move status is booked' do
    let(:move_status) { :booked }

    it_behaves_like 'the move changes but is not saved'
    it_behaves_like 'the move status changes to in_transit'

    context 'when the move has an associated PER' do
      subject(:generic_event) { build(:event_move_start, eventable: create(:move, move_status, :with_person_escort_record, person_escort_record_status: person_escort_record_status)) }

      let(:person_escort_record) { move.person_escort_record }

      context 'when the PER status is unstarted' do
        let(:person_escort_record_status) { 'unstarted' }

        it_behaves_like 'the move status changes to in_transit'
        it_behaves_like 'the PER status does not change'
        it_behaves_like 'a GenericEvent::PerConfirmation event is not created'
        it_behaves_like 'a per confirmation webhook is not sent'
      end

      context 'when the PER status is in_progress' do
        let(:person_escort_record_status) { 'in_progress' }

        it_behaves_like 'the move status changes to in_transit'
        it_behaves_like 'the PER status does not change'
        it_behaves_like 'a GenericEvent::PerConfirmation event is not created'
        it_behaves_like 'a per confirmation webhook is not sent'
      end

      context 'when the PER status is completed' do
        let(:person_escort_record_status) { 'completed' }

        it_behaves_like 'the move status changes to in_transit'
        it_behaves_like 'the PER status changes to confirmed'
        it_behaves_like 'a GenericEvent::PerConfirmation event is created'
        it_behaves_like 'a per confirmation webhook is sent'
      end

      context 'when the PER status is confirmed' do
        let(:person_escort_record_status) { 'confirmed' }

        it_behaves_like 'the move status changes to in_transit'
        it_behaves_like 'the PER status does not change'
        it_behaves_like 'a GenericEvent::PerConfirmation event is not created'
        it_behaves_like 'a per confirmation webhook is not sent'
      end
    end
  end

  context 'when the move status is in_transit' do
    let(:move_status) { :in_transit }

    it_behaves_like 'the move status does not change'
  end

  context 'when the move status is completed' do
    let(:move_status) { :completed }

    it_behaves_like 'the move status does not change'
  end

  context 'with generic event validation' do
    subject(:generic_event) { build(:event_move_start) }

    it_behaves_like 'a move event'
  end
end

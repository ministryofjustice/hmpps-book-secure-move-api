# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::MoveRunner do
  subject(:runner) { described_class.new(move) }

  let!(:move) { create(:move, :requested, to_location: original_location) }
  let(:original_location) { create(:location) }

  before { allow(Notifier).to receive(:prepare_notifications) }

  shared_examples_for 'it calls the Notifier with an update_status action_name' do
    before { runner.call }

    it 'calls the Notifier with update_status' do
      expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
    end
  end

  shared_examples_for 'it calls the Notifier with an update action_name' do
    before { runner.call }

    it 'calls the Notifier with update' do
      expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update')
    end
  end

  shared_examples_for 'it does not call the Notifier' do
    before do
      runner.call
    rescue ActiveRecord::RecordInvalid
      nil
    end

    it 'calls the Notifier with update' do
      expect(Notifier).not_to have_received(:prepare_notifications)
    end
  end

  context 'when event_name=redirect' do
    let!(:event1) { create(:move_event, :redirect, eventable: move, client_timestamp: event1_timestamp, created_at: 100.minutes.ago, details: event1_details) }
    let(:event1_details) do
      { note: 'Event1',
        event_params: {
          relationships: {
            to_location: { data: { id: event1_location.id } },
          },
        } }
    end
    let(:event1_location) { create(:location, title: 'Event1-Location') }

    let!(:event2) { create(:move_event, :redirect, eventable: move, client_timestamp: event2_timestamp, created_at: 1.minute.ago, details: event2_details) }
    let(:event2_details) do
      { note: 'Event2',
        event_params: {
          relationships: {
            to_location: { data: { id: event2_location.id } },
          },
        } }
    end
    let(:event2_location) { create(:location, title: 'Event2-Location') }

    context 'when events are received in a chronological order' do
      let(:event1_timestamp) { '2020-05-22 09:00:00' }  # chronologically first event created first
      let(:event2_timestamp) { '2020-05-22 10:00:00' }  # chronologically second event created second

      it 'updates the move to event2 redirect location' do
        expect { runner.call }.to change(move, :to_location).from(original_location).to(event2_location)
      end

      it_behaves_like 'it calls the Notifier with an update action_name'
    end

    context 'when events are not received in a chronological order' do
      let(:event1_timestamp) { '2020-05-22 10:00:00' } # chronologically second event created first
      let(:event2_timestamp) { '2020-05-22 09:00:00' } # chronologically first event created second

      it 'updates the move to event1 redirect location' do
        expect { runner.call }.to change(move, :to_location).from(original_location).to(event1_location)
      end

      it_behaves_like 'it calls the Notifier with an update action_name'
    end
  end

  context 'when event_name=cancel' do
    let!(:event) { create(:move_event, :cancel, eventable: move) }

    before do
      allow(Allocations::RemoveFromNomis).to receive(:call)
    end

    context 'when the move is requested' do
      it 'updates the move status to cancelled' do
        expect { runner.call }.to change(move, :status).from('requested').to('cancelled')
      end

      it 'updates the move cancellation_reason' do
        expect { runner.call }.to change(move, :cancellation_reason).from(nil).to('supplier_declined_to_move')
      end

      it 'updates the move cancellation_reason_comment' do
        expect { runner.call }.to change(move, :cancellation_reason_comment).from(nil).to('computer says no')
      end

      it 'removes prison transfer event from Nomis' do
        runner.call
        expect(Allocations::RemoveFromNomis).to have_received(:call).with(move)
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already cancelled' do
      let!(:move) { create(:move, :cancelled, cancellation_reason: 'supplier_declined_to_move', cancellation_reason_comment: 'computer says no') }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('cancelled')
      end
    end
  end

  context 'when event_name=approve' do
    let!(:event) { create(:move_event, :approve, eventable: move) }

    before do
      allow(Allocations::CreateInNomis).to receive(:call)
    end

    context 'when the move is proposed' do
      let!(:move) { create(:move, :proposed, date: Date.today) }

      it 'updates the move status to requested' do
        expect { runner.call }.to change(move, :status).from('proposed').to('requested')
      end

      it 'updates the move date' do
        expect { runner.call }.to change(move, :date).from(Date.today).to(Date.tomorrow)
      end

      it 'does not create a prison transfer event in Nomis' do
        runner.call
        expect(Allocations::CreateInNomis).not_to have_received(:call).with(move)
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already requested' do
      let!(:move) { create(:move, :requested, date: Date.tomorrow) }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('requested')
      end
    end

    context 'when creating in nomis is requested' do
      let!(:event) { create(:move_event, :approve_with_nomis, eventable: move) }

      it 'creates a prison transfer event in Nomis' do
        runner.call
        expect(Allocations::CreateInNomis).to have_received(:call).with(move)
      end
    end
  end

  context 'when event_name=accept' do
    let!(:event) { create(:move_event, :accept, eventable: move) }

    context 'when the move is requested' do
      let!(:move) { create(:move, :requested) }

      it 'updates the move status to booked' do
        expect { runner.call }.to change(move, :status).from('requested').to('booked')
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already booked' do
      let!(:move) { create(:move, :booked) }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('booked')
      end
    end
  end

  context 'when event_name=start' do
    let!(:event) { create(:move_event, :start, eventable: move) }

    context 'when the move is booked' do
      let!(:move) { create(:move, :booked) }

      it 'updates the move status to in_transit' do
        expect { runner.call }.to change(move, :status).from('booked').to('in_transit')
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already in_transit' do
      let!(:move) { create(:move, :in_transit) }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('in_transit')
      end
    end
  end

  context 'when event_name=reject' do
    let!(:event) { create(:move_event, :reject, eventable: move) }

    context 'when the move is requested' do
      it 'updates the move status to cancelled' do
        expect { runner.call }.to change(move, :status).from('requested').to('cancelled')
      end

      it 'updates the move rejection_reason' do
        expect { runner.call }.to change(move, :rejection_reason).from(nil).to('no_transport_available')
      end

      it 'updates the move cancellation_reason' do
        expect { runner.call }.to change(move, :cancellation_reason).from(nil).to('rejected')
      end

      it 'updates the move cancellation_reason_comment' do
        expect { runner.call }.to change(move, :cancellation_reason_comment).from(nil).to('computer says no')
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when a rebook is requested' do
      let!(:event) { create(:move_event, :reject_with_rebook, eventable: move) }

      it 'creates a new move' do
        expect { runner.call }.to change(Move, :count).by(1)
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already rejected' do
      let!(:move) { create(:move, :cancelled, rejection_reason: 'no_transport_available', cancellation_reason: 'rejected', cancellation_reason_comment: 'computer says no') }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('cancelled')
      end
    end
  end

  context 'when event_name=complete' do
    let!(:event) { create(:move_event, :complete, eventable: move) }

    context 'when the move is requested' do
      it 'updates the move status to completed' do
        expect { runner.call }.to change(move, :status).from('requested').to('completed')
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already completed' do
      let!(:move) { create(:move, :completed) }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('completed')
      end
    end
  end

  context 'when event_name=lockout' do
    # NB: lockout events have should have no effect on a move, they are purely for auditing
    let!(:event) { create(:move_event, :lockout, eventable: move) }

    it 'does not update the move status' do
      expect { runner.call }.not_to change(move, :status).from('requested')
    end

    it_behaves_like 'it does not call the Notifier'
  end

  context 'when the move record fails to save' do
    let!(:event) { create(:move_event, :broken_cancel, eventable: move) }

    it 'does not update the move status' do
      begin
        runner.call # this raises a validation error
      rescue ActiveRecord::RecordInvalid
        nil
      end
      expect(move.reload.status).to eql('requested')
    end

    it_behaves_like 'it does not call the Notifier'
  end
end

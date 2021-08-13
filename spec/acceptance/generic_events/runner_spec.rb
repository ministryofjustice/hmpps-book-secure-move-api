# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvents::Runner do
  describe 'Move events' do
    subject(:runner) { described_class.new(move) }

    let!(:move) { create(:move, :requested, to_location: original_location) }
    let(:original_location) { create(:location) }

    before do
      create :supplier_location, supplier: move.supplier, location: move.from_location

      allow(Notifier).to receive(:prepare_notifications)
    end

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
      context 'with multiple events' do
        let(:event1_location) { create(:location, title: 'Event1-Location') }
        let(:event2_location) { create(:location, title: 'Event2-Location') }

        context 'when events are received in a chronological order' do
          before do
            # chronologically first event created first
            create(:event_move_redirect, eventable: move, occurred_at: '2020-05-22 09:00:00', created_at: 100.minutes.ago, details: { to_location_id: event1_location.id })
            # chronologically second event created second
            create(:event_move_redirect, eventable: move, occurred_at: '2020-05-22 10:00:00', created_at: 1.minute.ago, details: { to_location_id: event2_location.id })
          end

          it 'updates the move to event2 redirect location' do
            expect { runner.call }.to change(move, :to_location).from(original_location).to(event2_location)
          end

          it_behaves_like 'it calls the Notifier with an update action_name'
        end

        context 'when events are not received in a chronological order' do
          before do
            # chronologically second event created first
            create(:event_move_redirect, eventable: move, occurred_at: '2020-05-22 10:00:00', created_at: 100.minutes.ago, details: { to_location_id: event1_location.id })
            # chronologically first event created second
            create(:event_move_redirect, eventable: move, occurred_at: '2020-05-22 09:00:00', created_at: 1.minute.ago, details: { to_location_id: event2_location.id })
          end

          it 'updates the move to event1 redirect location' do
            expect { runner.call }.to change(move, :to_location).from(original_location).to(event1_location)
          end

          it_behaves_like 'it calls the Notifier with an update action_name'
        end
      end

      context 'with invalid move_type' do
        let(:court_location) { create(:location, :court) }
        let(:invalid_event) { build(:event_move_redirect, eventable: move, details: { to_location_id: court_location.id, move_type: 'hospital' }) }

        before do
          invalid_event.save(validate: false)
        end

        it 'raises a validation error' do
          expect { runner.call }.to raise_error(ActiveRecord::RecordInvalid, /To location must be a hospital or high security hospital/i)
        end
      end
    end

    context 'when event_name=cancel' do
      before do
        create(:event_move_cancel, eventable: move)
        allow(Allocations::RemoveFromNomis).to receive(:call)
      end

      context 'when the move is requested' do
        it 'updates the move status to cancelled' do
          expect { runner.call }.to change(move, :status).from('requested').to('cancelled')
        end

        it 'updates the move cancellation_reason' do
          expect { runner.call }.to change(move, :cancellation_reason).from(nil).to('made_in_error')
        end

        it 'updates the move cancellation_reason_comment' do
          expect { runner.call }.to change(move, :cancellation_reason_comment).from(nil).to('It was a mistake')
        end

        it 'removes prison transfer event from Nomis' do
          runner.call
          expect(Allocations::RemoveFromNomis).to have_received(:call).with(move)
        end

        it_behaves_like 'it calls the Notifier with an update_status action_name'
      end

      context 'when the move is already cancelled' do
        let!(:move) { create(:move, :cancelled, cancellation_reason: 'made_in_error', cancellation_reason_comment: 'It was a mistake') }

        it_behaves_like 'it does not call the Notifier'

        it 'does not change the move status' do
          expect { runner.call }.not_to change(move, :status).from('cancelled')
        end
      end
    end

    context 'when event_name=approve' do
      let(:create_in_nomis) { false }

      before do
        create(:event_move_approve, eventable: move, details: { create_in_nomis: create_in_nomis, date: Date.tomorrow })
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
        let(:create_in_nomis) { true }

        it 'creates a prison transfer event in Nomis' do
          runner.call
          expect(Allocations::CreateInNomis).to have_received(:call).with(move)
        end
      end
    end

    context 'when event_name=accept' do
      before { create(:event_move_accept, eventable: move) }

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
      before { create(:event_move_start, eventable: move) }

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
      let!(:event) { create(:event_move_reject, eventable: move) }

      context 'when the move is requested' do
        it 'updates the move status to cancelled' do
          expect { runner.call }.to change(move, :status).from('requested').to('cancelled')
        end

        it 'updates the move rejection_reason' do
          expect { runner.call }.to change(move, :rejection_reason).from(nil).to('no_space_at_receiving_prison')
        end

        it 'updates the move cancellation_reason' do
          expect { runner.call }.to change(move, :cancellation_reason).from(nil).to('rejected')
        end

        it 'updates the move cancellation_reason_comment' do
          expect { runner.call }.to change(move, :cancellation_reason_comment).from(nil).to('It was a mistake')
        end

        it_behaves_like 'it calls the Notifier with an update_status action_name'
      end

      context 'when a rebook is requested' do
        let!(:event) { create(:event_move_reject, eventable: move) }

        before do
          event.details[:rebook] = true
          event.save
        end

        it 'creates a new move' do
          expect { runner.call }.to change(Move, :count).by(1)
        end

        it_behaves_like 'it calls the Notifier with an update_status action_name'
      end

      context 'when the move is already rejected' do
        let!(:move) { create(:move, :cancelled, rejection_reason: 'no_space_at_receiving_prison', cancellation_reason: 'rejected', cancellation_reason_comment: 'It was a mistake') }

        it_behaves_like 'it does not call the Notifier'

        it 'does not change the move status' do
          expect { runner.call }.not_to change(move, :status).from('cancelled')
        end
      end
    end

    context 'when event_name=complete' do
      before { create(:event_move_complete, eventable: move) }

      context 'when the move is requested' do
        let!(:move) { create(:move, :requested) }

        it 'does not change the move status' do
          expect { runner.call }.not_to change(move, :status).from('requested')
        end

        it_behaves_like 'it does not call the Notifier'
      end

      context 'when the move is in_transit' do
        let!(:move) { create(:move, :in_transit) }

        it 'updates the move status to completed' do
          expect { runner.call }.to change(move, :status).from('in_transit').to('completed')
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
      before { create(:event_move_lockout, eventable: move) }

      it 'does not update the move status' do
        expect { runner.call }.not_to change(move, :status).from('requested')
      end

      it_behaves_like 'it does not call the Notifier'
    end

    context 'when the move record fails to save' do
      let!(:event) { build(:event_move_cancel, eventable: move, details: event_details) }
      let(:event_details) do
        {
          cancellation_reason: 'foo',
          cancellation_reason_comment: 'It was a mistake',
        }
      end

      before do
        event.save(validate: false) # NB: We validate the cancellation_reason inside of the event model so need to skip this
      end

      it 'does not update the move status' do
        expect { runner.call }.to raise_error(ActiveRecord::RecordInvalid, /Cancellation reason is not included in the list/) # this raises a validation error}
      end

      it_behaves_like 'it does not call the Notifier'
    end
  end

  describe 'Journey events' do
    subject(:runner) { described_class.new(journey) }

    let(:journey) { create(:journey, initial_state) }

    shared_examples 'it does not change the state' do
      it 'does not update the journey state' do
        expect { runner.call }.not_to change(journey, :state).from(initial_state.to_s)
      end
    end

    shared_examples 'it changes the state to' do |new_state|
      it 'updates the journey state' do
        expect { runner.call }.to change(journey, :state).from(initial_state.to_s).to(new_state.to_s)
      end
    end

    describe 'proposed -> start + complete -> completed' do
      let(:initial_state) { :proposed }

      before do
        create(:event_journey_start, eventable: journey, occurred_at: 1.minute.ago)
        create(:event_journey_complete, eventable: journey, occurred_at: 1.minute.from_now)
      end

      it_behaves_like 'it changes the state to', :completed
    end

    describe 'completed -> uncomplete + cancel -> cancelled' do
      let(:initial_state) { :completed }

      before do
        create(:event_journey_uncomplete, eventable: journey, occurred_at: 1.minute.ago)
        create(:event_journey_cancel, eventable: journey, occurred_at: 1.minute.from_now)
      end

      it_behaves_like 'it changes the state to', :cancelled
    end

    describe 'proposed -> complete + cancel -> proposed' do
      let(:initial_state) { :proposed }

      before do
        create(:event_journey_complete, eventable: journey, occurred_at: 1.minute.ago)
        create(:event_journey_cancel, eventable: journey, occurred_at: 1.minute.from_now)
      end

      it_behaves_like 'it does not change the state' # NB: these are not valid events given the initial state so the state should not be updated
    end

    describe 'in_progress -> lodging + lockout -> in_progress' do
      let(:initial_state) { :in_progress }

      before do
        create(:event_journey_lodging, eventable: journey, occurred_at: 1.minute.ago)
        create(:event_journey_lockout, eventable: journey, occurred_at: 1.minute.from_now)
      end

      it_behaves_like 'it does not change the state'
    end
  end
end

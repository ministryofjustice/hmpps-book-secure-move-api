# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::MoveRunner do
  subject(:runner) { described_class.new(move) }

  let!(:move) { create(:move, to_location: original_location, status: move_status) }
  let(:original_location) { create(:location) }
  let(:move_status) { 'requested' }

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
    before { runner.call }

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

  context 'when event_name=complete' do
    let!(:event) { create(:move_event, :complete, eventable: move) }

    context 'when the move is requested' do
      it 'updates the move status to completed' do
        expect { runner.call }.to change(move, :status).from('requested').to('completed')
      end

      it_behaves_like 'it calls the Notifier with an update_status action_name'
    end

    context 'when the move is already completed' do
      let(:move_status) { 'completed' }

      it_behaves_like 'it does not call the Notifier'

      it 'does not change the move status' do
        expect { runner.call }.not_to change(move, :status).from('completed')
      end
    end
  end
end

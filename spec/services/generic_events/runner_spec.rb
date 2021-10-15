# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvents::Runner do
  subject(:runner) { described_class.new(eventable, dry_run: dry_run) }

  let(:eventable)           { create(:move) }
  let(:move_start_event)    { create(:event_move_start, eventable: eventable) }
  let(:move_complete_event) { create(:event_move_complete, eventable: eventable) }
  let(:move_cancel_event)   { create(:event_move_cancel, eventable: eventable) }

  let!(:events) { [move_start_event, move_complete_event, move_cancel_event] }

  before do
    allow(eventable).to receive(:generic_events) do
      class_double('GenericEvent', applied_order: events, where: events)
    end
    allow(eventable).to receive(:handle_event_run).and_call_original

    allow(move_start_event).to receive(:trigger).and_call_original
    allow(move_complete_event).to receive(:trigger).and_call_original
    allow(move_cancel_event).to receive(:trigger).and_call_original

    runner.call
  end

  context 'with dry_run: false' do
    let(:dry_run) { false }

    it 'calls #trigger against each event with dry_run: false' do
      expect(events).to all(have_received(:trigger).with(dry_run: false).ordered)
    end

    it 'calls #handle_event_run against the eventable with dry_run: false' do
      expect(eventable).to have_received(:handle_event_run).with(dry_run: false)
    end

    it 'yields each event to a block' do
      expect { |block| runner.call(&block) }.to yield_successive_args(*events)
    end

    it 'applies the events to eventable' do
      expect(eventable.status).to eql Move::MOVE_STATUS_CANCELLED
    end

    it 'saves the changes' do
      expect(eventable.changed?).to be false
      expect(eventable.reload.status).to eql Move::MOVE_STATUS_CANCELLED
    end
  end

  context 'with dry_run: true' do
    let(:dry_run) { true }

    it 'calls #trigger against each event with dry_run: true' do
      expect(events).to all(have_received(:trigger).with(dry_run: true).ordered)
    end

    it 'calls #handle_event_run against the eventable with dry_run: true' do
      expect(eventable).to have_received(:handle_event_run).with(dry_run: true)
    end

    it 'yields each event to a block' do
      expect { |block| runner.call(&block) }.to yield_successive_args(*events)
    end

    it 'applies the events to eventable' do
      expect(eventable.status).to eql Move::MOVE_STATUS_CANCELLED
    end

    it 'does not save the changes' do
      expect(eventable.changed?).to be true
      expect(eventable.reload.status).to eql Move::MOVE_STATUS_REQUESTED
    end
  end
end

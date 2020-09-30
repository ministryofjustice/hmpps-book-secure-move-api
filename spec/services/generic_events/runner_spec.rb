# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvents::Runner do
  subject(:runner) { described_class.new(eventable) }

  let(:eventable)           { create(:move) }
  let(:move_start_event)    { create(:event_move_start) }
  let(:move_complete_event) { create(:event_move_complete) }
  let(:move_reject_event)   { create(:event_move_reject) }

  let!(:events) { [move_start_event, move_complete_event, move_reject_event] }

  before do
    allow(eventable).to receive_message_chain('generic_events.applied_order').and_return(events)
    allow(eventable).to receive(:handle_run).and_call_original

    allow(move_start_event).to receive(:trigger).and_call_original
    allow(move_complete_event).to receive(:trigger).and_call_original
    allow(move_reject_event).to receive(:trigger).and_call_original
  end

  it 'calls #trigger against each event' do
    runner.call

    expect(move_start_event).to have_received(:trigger).ordered
    expect(move_complete_event).to have_received(:trigger).ordered
    expect(move_reject_event).to have_received(:trigger).ordered
  end

  it 'calls #handle_run against the eventable' do
    runner.call

    expect(eventable).to have_received(:handle_run)
  end
end

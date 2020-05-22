# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::MoveRunner do
  subject(:runner) { described_class.new(move) }

  let!(:move) { create(:move, to_location: original_location) }
  let!(:event1) do
    create(
      :move_event,
      event_type,
      eventable: move,
      client_timestamp: event1_timestamp,
      created_at: 100.minutes.ago,
      details: { note: 'Event1', event_params: { relationships: { to_location: { data: { id: event1_location.id } } } } },
    )
  end
  let!(:event2) do
    create(
      :move_event,
      event_type,
      eventable: move,
      client_timestamp: event2_timestamp,
      created_at: 1.minute.ago,
      details: { note: 'Event2', event_params: { relationships: { to_location: { data: { id: event2_location.id } } } } },
    )
  end

  let(:event_type) { :redirect }
  let(:original_location) { create(:location) }
  let(:event1_location) { create(:location, title: 'Event1-Location') }
  let(:event2_location) { create(:location, title: 'Event2-Location') }
  let(:event1_timestamp) { '2020-05-22 09:00:00' }
  let(:event2_timestamp) { '2020-05-22 10:00:00' }

  context 'when events are received in a chronological order' do
    it 'updates the move to event2 redirect location' do
      expect { runner.call }.to change(move, :to_location).from(original_location).to(event2_location)
    end
  end

  context 'when events are not received in a chronological order' do
    let(:event1_timestamp) { '2020-05-22 10:00:00' } # chronological second event received first
    let(:event2_timestamp) { '2020-05-22 09:00:00' } # chronological first event received last

    it 'updates the move to event1 redirect location' do
      expect { runner.call }.to change(move, :to_location).from(original_location).to(event1_location)
    end
  end

  context 'when the events are not redirects' do
    let(:event_type) { :lockout }

    it 'does not update the moves to_location' do
      expect { runner.call }.not_to change(move, :to_location).from(original_location)
    end
  end
end

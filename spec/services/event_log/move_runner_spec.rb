# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::MoveRunner do
  subject(:runner) { described_class.new(move) }

  let!(:move) { create(:move) }
  let!(:event1) { create(:move_event, :redirect, eventable: move, client_timestamp: timestamp1) }
  let!(:event2) { create(:move_event, :redirect, eventable: move, client_timestamp: timestamp2) }

  context 'when events are received in a chronological order' do
    let(:timestamp1) { '2020-05-22 09:00:00' }
    let(:timestamp2) { '2020-05-22 10:00:00' }

    it 'updates the move to event2 redirect location' do
      expect { runner.call }.to change(move, :to_location).to(event2.to_location)
    end
  end

  context 'when events are received in a different order' do
    let(:timestamp1) { '2020-05-22 10:00:00' }
    let(:timestamp2) { '2020-05-22 09:00:00' }

    it 'updates the move to event2 redirect location' do
      expect { runner.call }.to change(move, :to_location).to(event1.to_location)
    end
  end
end

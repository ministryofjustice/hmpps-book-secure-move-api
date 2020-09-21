# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::JourneyExecutor do
  subject(:journey_executor) { described_class.new(journey) }

  let(:journey) { create(:journey, initial_state) }

  shared_examples 'it does not change the state' do
    it 'does not update the journey state' do
      expect { journey_executor.call }.not_to change(journey, :state).from(initial_state.to_s)
    end
  end

  shared_examples 'it changes the state to' do |new_state|
    it 'updates the journey state' do
      expect { journey_executor.call }.to change(journey, :state).from(initial_state.to_s).to(new_state.to_s)
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

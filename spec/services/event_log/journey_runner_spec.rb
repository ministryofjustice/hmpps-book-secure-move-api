# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::JourneyRunner do
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
      create(:event, :start, eventable: journey, client_timestamp: 1.minute.ago)
      create(:event, :complete, eventable: journey, client_timestamp: 1.minute.from_now)
    end

    it_behaves_like 'it changes the state to', :completed
  end

  describe 'completed -> uncomplete + cancel -> cancelled' do
    let(:initial_state) { :completed }

    before do
      create(:event, :uncomplete, eventable: journey, client_timestamp: 1.minute.ago)
      create(:event, :cancel, eventable: journey, client_timestamp: 1.minute.from_now)
    end

    it_behaves_like 'it changes the state to', :cancelled
  end

  describe 'proposed -> complete + cancel -> proposed' do
    let(:initial_state) { :proposed }

    before do
      create(:event, :complete, eventable: journey, client_timestamp: 1.minute.ago)
      create(:event, :cancel, eventable: journey, client_timestamp: 1.minute.from_now)
    end

    it_behaves_like 'it does not change the state' # NB: these are not valid events given the initial state so the state should not be updated
  end

  describe 'in_progress -> lodging + lockout -> in_progress' do
    let(:initial_state) { :in_progress }

    before do
      create(:event, :lodging, eventable: journey, client_timestamp: 1.minute.ago)
      create(:event, :lockout, eventable: journey, client_timestamp: 1.minute.from_now)
    end

    it_behaves_like 'it does not change the state'
  end
end

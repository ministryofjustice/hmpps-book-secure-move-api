# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLog::JourneyRunner do
  subject(:runner) { described_class.new(journey) }

  let(:journey) { create(:journey, inital_state) }

  shared_examples 'it does not change the state' do
    it 'does not update the journey state' do
      expect { runner.call }.not_to change(journey, :state).from(inital_state.to_s)
    end
  end

  shared_examples 'it changes the state to' do |new_state|
    it 'updates the journey state' do
      expect { runner.call }.to change(journey, :state).from(inital_state.to_s).to(new_state.to_s)
    end
  end

  describe 'start event' do
    let!(:event) { create(:event, :start, eventable: journey) }

    context 'when the journey is proposed' do
      let(:inital_state) { :proposed }

      it_behaves_like 'it changes the state to', :in_progress
    end

    context 'when the journey is already in_progress' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end
  end

  describe 'reject event' do
    let!(:event) { create(:event, :reject, eventable: journey) }

    context 'when the journey is proposed' do
      let(:inital_state) { :proposed }

      it_behaves_like 'it changes the state to', :rejected
    end

    context 'when the journey is already rejected' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it does not change the state'
    end
  end

  describe 'cancel event' do
    let!(:event) { create(:event, :cancel, eventable: journey) }

    context 'when the journey is in_progress' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it changes the state to', :cancelled
    end

    context 'when the journey is already cancelled' do
      let(:inital_state) { :cancelled }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end
  end

  describe 'complete event' do
    let!(:event) { create(:event, :complete, eventable: journey) }

    context 'when the journey is in_progress' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it changes the state to', :completed
    end

    context 'when the journey is already completed' do
      let(:inital_state) { :completed }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end
  end

  describe 'uncancel event' do
    let!(:event) { create(:event, :uncancel, eventable: journey) }

    context 'when the journey is cancelled' do
      let(:inital_state) { :cancelled }

      it_behaves_like 'it changes the state to', :in_progress
    end

    context 'when the journey is already in_progress' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end
  end

  describe 'uncomplete event' do
    let!(:event) { create(:event, :uncomplete, eventable: journey) }

    context 'when the journey is completed' do
      let(:inital_state) { :completed }

      it_behaves_like 'it changes the state to', :in_progress
    end

    context 'when the journey is already in_progress' do
      let(:inital_state) { :in_progress }

      it_behaves_like 'it does not change the state'
    end

    context 'when the journey is in an irrelevant state' do
      let(:inital_state) { :rejected }

      it_behaves_like 'it does not change the state'
    end
  end
end

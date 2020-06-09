# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JourneyStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:state).new(initial_state) } # NB: the target is not updated until an event fires
  let(:initial_state) { :proposed }

  before { machine.restore!(initial_state) }

  shared_examples 'state_machine target state' do |expected_state|
    describe 'machine state' do
      it { expect(machine.current).to eql expected_state }
    end

    describe 'target state' do
      it { expect(target.state).to eql expected_state }
    end
  end

  it { is_expected.to respond_to(:start, :reject, :cancel, :uncancel, :complete, :uncomplete, :restore!, :current) }

  context 'when in the proposed state' do
    it_behaves_like 'state_machine target state', :proposed

    context 'when the start event is fired' do
      before { machine.start }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the reject event is fired' do
      before { machine.reject }

      it_behaves_like 'state_machine target state', :rejected
    end
  end

  context 'when in the in_progress state' do
    let(:initial_state) { :in_progress }

    it_behaves_like 'state_machine target state', :in_progress

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :completed
    end

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target state', :cancelled
    end

    context 'when the uncancel event is fired' do
      before { machine.uncancel }

      it_behaves_like 'state_machine target state', :in_progress
    end
  end

  context 'when in the completed state' do
    let(:initial_state) { :completed }

    it_behaves_like 'state_machine target state', :completed

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :completed
    end

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target state', :completed
    end

    context 'when the uncancel event is fired' do
      before { machine.uncancel }

      it_behaves_like 'state_machine target state', :completed
    end
  end

  context 'when in the cancelled state' do
    let(:initial_state) { :cancelled }

    it_behaves_like 'state_machine target state', :cancelled

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :cancelled
    end

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :cancelled
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target state', :cancelled
    end

    context 'when the uncancel event is fired' do
      before { machine.uncancel }

      it_behaves_like 'state_machine target state', :in_progress
    end
  end
end

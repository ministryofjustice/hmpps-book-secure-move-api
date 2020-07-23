# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:state).new(initial_state) }
  let(:initial_state) { :unstarted }

  before { machine.restore!(initial_state) }

  it { is_expected.to respond_to(:complete, :uncomplete, :confirm, :to_print) }

  context 'when in the unstarted state' do
    it_behaves_like 'state_machine target state', :unstarted

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :completed
    end
  end

  context 'when in the in_progress state' do
    let(:initial_state) { :in_progress }

    it_behaves_like 'state_machine target state', :in_progress

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :completed
    end
  end

  context 'when in the completed state' do
    let(:initial_state) { :completed }

    it_behaves_like 'state_machine target state', :completed

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the confirm event is fired' do
      before { machine.confirm }

      it_behaves_like 'state_machine target state', :confirmed
    end
  end

  context 'when in the confirmed state' do
    let(:initial_state) { :confirmed }

    it_behaves_like 'state_machine target state', :confirmed

    context 'when the to_print event is fired' do
      before { machine.to_print }

      it_behaves_like 'state_machine target state', :printed
    end
  end

  context 'when in the printed state' do
    let(:initial_state) { :printed }

    it_behaves_like 'state_machine target state', :printed
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:state, :confirmed_at, :printed_at).new(initial_state) }
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

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end
  end

  context 'when in the completed state' do
    let(:initial_state) { :completed }

    it_behaves_like 'state_machine target state', :completed

    context 'when the uncomplete event is fired' do
      before { machine.uncomplete }

      it_behaves_like 'state_machine target state', :in_progress
    end

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target state', :completed
    end

    context 'when the confirm event is fired' do
      let(:confirmed_at_timstamp) { Time.zone.now }

      before do
        allow(Time).to receive(:now).and_return(confirmed_at_timstamp)
        machine.confirm
      end

      it_behaves_like 'state_machine target state', :confirmed

      it 'sets the current timestamp to confirmed_at' do
        expect(target.confirmed_at).to eq(confirmed_at_timstamp)
      end
    end
  end

  context 'when in the confirmed state' do
    let(:initial_state) { :confirmed }
    let(:printed_at_timstamp) { Time.zone.now }

    it_behaves_like 'state_machine target state', :confirmed

    context 'when the to_print event is fired' do
      before do
        allow(Time).to receive(:now).and_return(printed_at_timstamp)
        machine.to_print
      end

      it_behaves_like 'state_machine target state', :printed

      it 'sets the current timestamp to printed_at' do
        expect(target.printed_at).to eq(printed_at_timstamp)
      end
    end
  end

  context 'when in the printed state' do
    let(:initial_state) { :printed }

    it_behaves_like 'state_machine target state', :printed
  end
end

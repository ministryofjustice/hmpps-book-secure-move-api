# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LodgingStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:status).new(initial_state) }
  let(:initial_state) { :proposed }

  before { machine.restore!(initial_state) }

  it { is_expected.to respond_to(:start, :complete, :cancel) }

  context 'when in the proposed state' do
    it_behaves_like 'state_machine target status', :proposed

    context 'when the start event is fired' do
      before { machine.start }

      it_behaves_like 'state_machine target status', :started
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target status', :cancelled
    end
  end

  context 'when in the started status' do
    let(:initial_state) { :started }

    it_behaves_like 'state_machine target status', :started

    context 'when the complete event is fired' do
      before { machine.complete }

      it_behaves_like 'state_machine target status', :completed
    end
  end
end

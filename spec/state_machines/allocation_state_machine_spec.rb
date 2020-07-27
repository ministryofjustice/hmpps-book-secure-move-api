# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { Struct.new(:status).new(initial_state) }
  let(:initial_state) { :unfilled }

  before { machine.restore!(initial_state) }

  it { is_expected.to respond_to(:fill, :unfill, :cancel) }

  context 'when in the unfilled status' do
    it_behaves_like 'state_machine target status', :unfilled

    context 'when the fill event is fired' do
      before { machine.fill }

      it_behaves_like 'state_machine target status', :filled
    end

    context 'when the unfill event is fired' do
      before { machine.unfill }

      it_behaves_like 'state_machine target status', :unfilled
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target status', :cancelled
    end
  end

  context 'when in the filled status' do
    let(:initial_state) { :filled }

    it_behaves_like 'state_machine target status', :filled

    context 'when the unfill event is fired' do
      before { machine.unfill }

      it_behaves_like 'state_machine target status', :unfilled
    end

    context 'when the fill event is fired' do
      before { machine.fill }

      it_behaves_like 'state_machine target status', :filled
    end

    context 'when the cancel event is fired' do
      before { machine.cancel }

      it_behaves_like 'state_machine target status', :cancelled
    end
  end

  context 'when in the cancelled status' do
    let(:initial_state) { :cancelled }

    it_behaves_like 'state_machine target status', :cancelled

    context 'when the fill event is fired' do
      before { machine.fill }

      it_behaves_like 'state_machine target status', :cancelled
    end

    context 'when the unfill event is fired' do
      before { machine.unfill }

      it_behaves_like 'state_machine target status', :cancelled
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationStateMachine do
  let(:machine) { described_class.new(target) }
  let(:target) { build(:allocation) }
  let(:initial_state) { :unfilled }

  before { machine.restore!(initial_state) }

  shared_examples 'state_machine target status' do |expected_status|
    describe 'machine status' do
      it { expect(machine.current).to eql expected_status }
    end

    describe 'target status' do
      it { expect(target.status).to eql expected_status.to_s }
    end
  end

  context 'when in the unfilled status' do
    it_behaves_like 'state_machine target status', :unfilled
  end
end

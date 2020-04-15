# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journey, type: :model do
  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }

  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:supplier) }
  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_exclusion_of(:billable).in_array([nil]) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w(in_progress completed cancelled)) }
  it { is_expected.to respond_to(:cancel, :un_cancel, :complete, :un_complete) }
  it { expect(described_class).to respond_to(:default_order) }

  shared_examples 'synchronised state' do |expected_state|
    it { expect(state).to eql expected_state.to_s }
    it { expect(state_machine_state).to eql expected_state.to_sym }
  end

  shared_examples 'unsynchronised state' do
    it { expect(state_machine_state.to_s).not_to eql state }
  end

  shared_examples 'state synchronisation examples' do
    context 'when nil state' do
      it_behaves_like 'synchronised state', :in_progress
    end

    context 'when specified state' do
      let(:initial_state) { 'completed' }

      it_behaves_like 'synchronised state', :completed
    end

    context 'when invalid state' do
      let(:initial_state) { 'foo' }

      it_behaves_like 'synchronised state', :foo
    end

    context 'when the state changes with an event' do
      before { journey.cancel }

      it_behaves_like 'synchronised state', :cancelled
    end

    context 'when the state is manually changed' do
      before { journey.state = 'completed' }

      it_behaves_like 'unsynchronised state'
    end
  end

  describe 'state_machine <--> state synchronisation' do
    # These tests verify that the synchronisation between journey.state and the internal state_machine behave as expected
    # for initialised, created, found and built records

    let(:initial_state) { nil }
    let(:state) { journey.state }
    let(:state_machine_state) { journey.send(:state_machine).current }

    context 'when initialized' do
      let(:journey) { described_class.new(state: initial_state) }

      it_behaves_like 'state synchronisation examples'
    end

    context 'when created' do
      let(:journey) { described_class.create(state: initial_state) }

      it_behaves_like 'state synchronisation examples'
    end

    context 'when built with factory bot' do
      let(:journey) { build(:journey, state: initial_state) }

      it_behaves_like 'state synchronisation examples'
    end

    context 'when loaded from the database' do
      # NB: disabling the validation on save to allow the "foo" state to persist
      before { build(:journey, state: initial_state).save(validate: false) }

      let(:journey) { described_class.first }

      it_behaves_like 'state synchronisation examples'
    end
  end
end

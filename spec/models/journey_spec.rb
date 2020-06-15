# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journey, type: :model do
  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }
  it { is_expected.to have_many(:events) }
  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:supplier) }
  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_exclusion_of(:billable).in_array([nil]) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w[proposed rejected in_progress completed cancelled]) }
  it { is_expected.to respond_to(:start, :reject, :cancel, :uncancel, :complete, :uncomplete) }
  it { expect(described_class).to respond_to(:default_order) }

  shared_examples 'model is synchronised with state_machine' do |expected_state|
    describe 'machine state' do
      it { expect(state_machine_state).to eql expected_state.to_sym }
    end

    describe 'model state' do
      it { expect(state).to eql expected_state.to_s }
    end
  end

  shared_examples 'model is synchronised with state_machine for events and initialization' do
    context 'when nil state' do
      it_behaves_like 'model is synchronised with state_machine', :proposed
    end

    context 'when specified state' do
      let(:initial_state) { 'completed' }

      it_behaves_like 'model is synchronised with state_machine', :completed
    end

    context 'when invalid state' do
      let(:initial_state) { 'foo' }

      it_behaves_like 'model is synchronised with state_machine', :foo
    end

    context 'when the state changes with an event' do
      before { journey.start }

      it_behaves_like 'model is synchronised with state_machine', :in_progress
    end

    context 'when the model state is manually updated outside of the state_machine' do
      before { journey.state = 'foo' }

      # NB: they are NOT synchronised because the change was not made via the state_machine
      it { expect(state_machine_state.to_s).not_to eql state }
    end
  end

  describe 'state_machine <--> journey state synchronisation' do
    # These tests verify that the synchronisation between journey.state and the internal state_machine behave as expected
    # for initialised, created, found and built records

    let(:initial_state) { nil }
    let(:state) { journey.state }
    let(:state_machine_state) { journey.send(:state_machine).current }

    context 'when initialized' do
      let(:journey) { described_class.new(state: initial_state) }

      it_behaves_like 'model is synchronised with state_machine for events and initialization'
    end

    context 'when created' do
      let(:journey) { described_class.create(state: initial_state) }

      it_behaves_like 'model is synchronised with state_machine for events and initialization'
    end

    context 'when built with factory bot' do
      let(:journey) { build(:journey, state: initial_state) }

      it_behaves_like 'model is synchronised with state_machine for events and initialization'
    end

    context 'when loaded from the database' do
      # NB: disabling the validation on save to allow the "foo" state to persist
      before { build(:journey, state: initial_state).save(validate: false) }

      let(:journey) { described_class.first }

      it_behaves_like 'model is synchronised with state_machine for events and initialization'
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journey, type: :model do
  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }
  it { is_expected.to have_many(:generic_events) }
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

  describe '#not_rejected_or_cancelled' do
    subject(:results) { described_class.not_rejected_or_cancelled }

    context 'with a completed journey' do
      let(:journey) { create(:journey, :completed) }

      it { is_expected.to contain_exactly(journey) }
    end

    context 'with a rejected journey' do
      before { create(:journey, :rejected) }

      it { is_expected.to be_empty }
    end

    context 'with a cancelled journey' do
      before { create(:journey, :cancelled) }

      it { is_expected.to be_empty }
    end
  end

  context 'when the from_location and to_location are the same' do
    subject(:journey) { build(:journey, to_location: location, from_location: location) }

    let(:location) { create(:location) }

    it 'is not valid' do
      expect(journey).not_to be_valid
      expect(journey.errors[:to_location_id]).to eq(['should be different to the from location'])
    end
  end

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

  describe 'relationships' do
    it 'updates the parent record when updated' do
      move = create(:move)
      journey = create(:journey, move:)

      expect { journey.update(billable: !journey.billable) }.to(change { move.reload.updated_at })
    end

    it 'updates the parent record when created' do
      move = create(:move)

      expect { create(:journey, move:) }.to(change { move.reload.updated_at })
    end
  end

  describe '#for_feed' do
    let(:journey) { create(:journey) }

    let(:expected_json) do
      {
        'id': journey.id,
        'move_id': journey.move.id,
        'supplier': journey.supplier.key,
        'from_location': 'PEI',
        'from_location_type': 'prison',
        'to_location': 'GUICCT',
        'to_location_type': 'court',
        'billable': false,
        'date': be_a(Date),
        'state': 'proposed',
        'vehicle_registration': 'AB12 CDE',
        'vehicle_depot': 'Depot 1',
        'client_timestamp': be_a(Time),
        'created_at': be_a(Time),
        'updated_at': be_a(Time),
      }
    end

    it 'generates a feed document' do
      expect(journey.for_feed).to include_json(expected_json)
    end
  end

  describe '#handle_event_run' do
    subject(:journey) { create(:journey) }

    context 'when the journey has changed but is not valid' do
      before do
        journey.state = 'foo'
      end

      it 'does not save the journey' do
        journey.handle_event_run

        expect(journey.reload.state).not_to eq('foo')
      end
    end

    context 'when the journey has changed and is valid' do
      before do
        journey.state = 'in_progress'
      end

      it 'saves the journey' do
        journey.handle_event_run

        expect(journey.reload.state).to eq('in_progress')
      end
    end

    context 'when dry_run: true' do
      before do
        journey.state = 'in_progress'
      end

      it 'does not save the journey' do
        journey.handle_event_run(dry_run: true)

        expect(journey).to be_changed
        expect(journey.reload.state).to eq('proposed')
      end
    end
  end

  describe '#vehicle_registration=' do
    subject(:journey) { build(:journey) }

    let(:new_registration) { 'AB12 CDF' }

    context 'when vehicle was already present' do
      before do
        journey.vehicle = { id: '12345678ABC', registration: 'AB12 CDE' }
      end

      it 'assigns the new vehicle registration value' do
        expect { journey.vehicle_registration = new_registration }.to change(journey, :vehicle_registration).from('AB12 CDE').to('AB12 CDF')
      end
    end

    context 'when vehicle was not already present' do
      before do
        journey.vehicle = nil
      end

      it 'assigns the new registration' do
        expect { journey.vehicle_registration = new_registration }.to change(journey, :vehicle_registration).from(nil).to('AB12 CDF')
      end
    end
  end

  describe '#vehicle_depot=' do
    subject(:journey) { build(:journey) }

    let(:new_depot) { 'Depot 2' }

    context 'when vehicle was already present' do
      before do
        journey.vehicle = { id: '12345678ABC', registration: 'AB12 CDE', depot: 'Depot 1' }
      end

      it 'assigns the new vehicle depot value' do
        expect { journey.vehicle_depot = new_depot }.to change(journey, :vehicle_depot).from('Depot 1').to('Depot 2')
      end
    end

    context 'when vehicle was not already present' do
      before do
        journey.vehicle = nil
      end

      it 'assigns the new depot' do
        expect { journey.vehicle_depot = new_depot }.to change(journey, :vehicle_depot).from(nil).to('Depot 2')
      end
    end
  end

  describe '#number' do
    let(:move) { create(:move) }
    let(:journey_1) { create(:journey, move:, client_timestamp: Date.new(2020, 1, 1)) }
    let(:journey_2) { create(:journey, move:, client_timestamp: Date.new(2020, 1, 2)) }

    it 'has the correct journey number' do
      expect(journey_1.number).to eq(1)
      expect(journey_2.number).to eq(2)
    end
  end

  describe 'versioning' do
    let(:journey) { create(:journey) }

    it 'has an audit' do
      expect(journey.versions.map(&:event)).to eq(%w[create])
    end

    it 'updates the audit' do
      journey.reject
      journey.save!
      expect(journey.versions.map(&:event)).to eq(%w[create update])
    end
  end
end

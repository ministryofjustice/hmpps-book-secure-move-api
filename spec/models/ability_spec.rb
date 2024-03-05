require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(application) }

  context 'when application.owner is the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.to be_able_to(:manage, Move.new(supplier: owner_supplier)) }
  end

  context 'when application.owner is NOT the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.not_to be_able_to(:manage, Move.new(supplier: another_supplier)) }
  end

  context 'when there is a cross-supplier move' do
    let(:supplier_a) { create :supplier }
    let(:supplier_b) { create :supplier }
    let(:move) do
      location_a = create(:location, suppliers: [supplier_a])
      location_b = create(:location, suppliers: [supplier_b])
      create(:move, from_location: location_a, to_location: location_b)
    end

    shared_examples 'move is accessible' do
      let(:application) { Doorkeeper::Application.create(name: 'test', owner: supplier) }

      it { is_expected.to be_able_to(:manage, move) }

      it 'finds the move when queried' do
        expect(Move.accessible_by(ability)).to eq([move])
      end
    end

    context 'with supplier A' do
      let(:supplier) { supplier_a }

      include_examples 'move is accessible'
    end

    context 'with supplier B' do
      let(:supplier) { supplier_b }

      include_examples 'move is accessible'
    end
  end

  context 'when there is a move with cross-supplier lodging' do
    let(:supplier_a) { create :supplier }
    let(:supplier_b) { create :supplier }
    let(:move) do
      location_a = create(:location, suppliers: [supplier_a])
      location_b = create(:location, suppliers: [supplier_a])
      lodge_location = create(:location, suppliers: [supplier_b])
      move = create(:move, from_location: location_a, to_location: location_b)
      create(:lodging, move:, location: lodge_location)

      move
    end

    shared_examples 'move is accessible' do
      let(:application) { Doorkeeper::Application.create(name: 'test', owner: supplier) }

      it { is_expected.to be_able_to(:manage, move) }

      it 'finds the move when queried' do
        expect(Move.accessible_by(ability)).to eq([move])
      end
    end

    context 'with supplier A' do
      let(:supplier) { supplier_a }

      include_examples 'move is accessible'
    end

    context 'with supplier B' do
      let(:supplier) { supplier_b }

      include_examples 'move is accessible'
    end
  end

  context 'when application is owned by frontend application' do
    let(:application) { Doorkeeper::Application.create(name: 'test') }

    it { is_expected.to be_able_to(:manage, Move.new) }
    it { is_expected.to be_able_to(:manage, Journey.new) }
    it { is_expected.to be_able_to(:manage, Lodging.new) }
  end

  context 'when application is absent' do
    let(:application) { nil }

    it { is_expected.not_to be_able_to(:manage, Move.new) }
  end
end

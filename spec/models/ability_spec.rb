require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(application) }

  context 'when application is owned the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.to be_able_to(:manage, Move.new(supplier: owner_supplier)) }
  end

  context 'when application is NOT owned the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.not_to be_able_to(:manage, Move.new(supplier: another_supplier)) }
  end

  context 'when application is owned by cross-supplier move' do
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

    context 'and as supplier A' do
      let(:supplier) { supplier_a }

      include_examples 'move is accessible'
    end

    context 'and as supplier B' do
      let(:supplier) { supplier_b }

      include_examples 'move is accessible'
    end
  end

  context 'when application is owned by frontend application' do
    let(:application) { Doorkeeper::Application.create(name: 'test') }

    it { is_expected.to be_able_to(:manage, Move.new) }
  end

  context 'when application is absent' do
    let(:application) { nil }

    it { is_expected.not_to be_able_to(:manage, Move.new) }
  end
end

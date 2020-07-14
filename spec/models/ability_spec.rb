require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(application) }

  context 'when application is owned the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.to be_able_to(:manage, Move.new(supplier: owner_supplier) ) }
  end

  context 'when application is NOT owned the supplier of the move' do
    let(:owner_supplier) { create :supplier }
    let(:another_supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test', owner: owner_supplier) }

    it { is_expected.not_to be_able_to(:manage, Move.new(supplier: another_supplier) ) }
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

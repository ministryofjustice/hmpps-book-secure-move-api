require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(application) }

  context 'when application is owned by a supplier' do
    let(:supplier) { create :supplier }
    let(:application) { Doorkeeper::Application.create(name: 'test') }
    let(:location) { create :location, :with_moves, suppliers: [supplier] }

    it { is_expected.to be_able_to(:manage, location.moves_from.build) }
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

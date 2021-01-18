# frozen_string_literal: true

require 'rails_helper'

# NB: the mock class name must be unique in test suite
class MockMetricsMovesSerco
  include Metrics::Moves::SercoMoves
end

RSpec.describe MockMetricsMovesSerco do
  describe 'database' do
    subject { described_class.new.database }

    it { is_expected.to eql('moves_serco') }
  end

  describe 'moves' do
    subject { described_class.new.moves }

    let(:serco) { create(:supplier, :serco) }
    let(:serco_moves) { create_list(:move, 2, supplier: serco) }
    let(:other_moves) { create_list(:move, 2) }

    before do
      serco_moves
      other_moves
    end

    it { is_expected.to match_array(serco_moves) }
  end

  describe 'serco' do
    subject { described_class.new.serco }

    let(:geoamey) { create(:supplier, :geoamey) }
    let(:serco) { create(:supplier, :serco) }

    before do
      geoamey
      serco
    end

    it { is_expected.to eql(serco) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

# NB: the mock class name must be unique in test suite
class MockMetricsMovesGeoamey
  include Metrics::Moves::GeoameyMoves
end

RSpec.describe MockMetricsMovesGeoamey do
  describe 'database' do
    subject { described_class.new.database }

    it { is_expected.to eql('moves_geoamey') }
  end

  describe 'moves' do
    subject { described_class.new.moves }

    let(:geoamey) { create(:supplier, :geoamey) }
    let(:geo_moves) { create_list(:move, 2, supplier: geoamey) }
    let(:other_moves) { create_list(:move, 2) }

    before do
      geo_moves
      other_moves
    end

    it { is_expected.to match_array(geo_moves) }
  end

  describe 'geoamey' do
    subject { described_class.new.geoamey }

    let(:geoamey) { create(:supplier, :geoamey) }
    let(:serco) { create(:supplier, :serco) }

    before do
      geoamey
      serco
    end

    it { is_expected.to eql(geoamey) }
  end
end

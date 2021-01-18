# frozen_string_literal: true

require 'rails_helper'

# NB: the mock class name must be unique in test suite
class MockMetricsMoves
  include Metrics::Moves
end

RSpec.describe MockMetricsMoves do
  describe 'database' do
    subject { described_class.new.database }

    it { is_expected.to eql('moves') }
  end

  describe 'moves' do
    subject { described_class.new.moves }

    let(:moves) { create_list(:move, 2) }

    before do
      moves
    end

    it { is_expected.to match_array(moves) }
  end
end

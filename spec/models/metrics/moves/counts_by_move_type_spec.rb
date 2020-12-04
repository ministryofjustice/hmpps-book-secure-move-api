# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveType do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    before do
      create(:move, :court_appearance)
      create(:move, :prison_recall)
      create(:move, :hospital)
      create(:move, :hospital)
    end

    it 'computes the metric' do
      expect(metric.calculate(:court_appearance, 'total')).to be(1)
      expect(metric.calculate(:hospital, 'total')).to be(2)
    end
  end
end

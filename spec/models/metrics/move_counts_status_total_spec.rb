# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::MoveCountsStatusTotal do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes metric_label' do
    expect(metric.metric_label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    before do
      create(:move, :proposed)
      create(:move, :requested)
      create(:move, :requested)
      create(:move, :completed)
    end

    it 'computes the metric' do
      expect(metric.calculate('proposed', 'total')).to be(1)
      expect(metric.calculate('requested', 'total')).to be(2)
    end
  end
end

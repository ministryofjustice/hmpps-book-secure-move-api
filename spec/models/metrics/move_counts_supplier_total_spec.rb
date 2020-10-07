# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::MoveCountsSupplierTotal do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes metric_label' do
    expect(metric.metric_label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :proposed)
      create(:move, :proposed, supplier: supplier1)
      create(:move, :in_transit, supplier: supplier1)
      create(:move, :proposed, supplier: supplier2)
    end

    it 'computes the metric' do
      expect(metric.calculate(supplier1, 'total')).to be(2)
    end
  end
end

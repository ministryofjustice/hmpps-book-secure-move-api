# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsBySupplierMoveType do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :prison_recall, supplier: supplier1)
      create(:move, :prison_recall, supplier: supplier1)
      create(:move, :prison_transfer, supplier: supplier2)
      create(:move, :hospital, supplier: supplier2)
    end

    it 'computes the metric' do
      expect(metric.calculate(supplier1, :prison_recall)).to be(2)
      expect(metric.calculate(supplier2, :hospital)).to be(1)
    end
  end
end

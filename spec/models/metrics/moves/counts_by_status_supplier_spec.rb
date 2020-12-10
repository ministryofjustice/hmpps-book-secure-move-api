# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatusSupplier do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(supplier1) }

    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :proposed, supplier: supplier1)
      create(:move, :proposed, supplier: supplier1)
      create(:move, :in_transit, supplier: supplier1)
      create(:move, :proposed, supplier: supplier2)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'in_transit' => 1,
          'proposed' => 2,
        },
      )
    end
  end
end

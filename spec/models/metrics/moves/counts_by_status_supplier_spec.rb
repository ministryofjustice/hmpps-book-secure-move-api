# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatusSupplier do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('moves/counts_by_status_supplier')
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
          'total' => 3,
        },
      )
    end
  end
end

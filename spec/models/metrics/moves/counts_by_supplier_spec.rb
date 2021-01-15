# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsBySupplier do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('moves/counts_by_supplier')
  end

  describe 'calculate_row' do
    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :proposed, supplier: supplier1)
      create(:move, :proposed, supplier: supplier1)
      create(:move, :in_transit, supplier: supplier1)
      create(:move, :proposed, supplier: supplier2)
    end

    it 'computes the metric' do
      expect(metric.calculate('count', supplier1)).to be(3)
      expect(metric.calculate('count', supplier2)).to be(1)
    end
  end
end

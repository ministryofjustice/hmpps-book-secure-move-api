# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveTypeSupplier do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('moves/counts_by_move_type_supplier')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(supplier2) }

    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :prison_recall, supplier: supplier1)
      create(:move, :prison_recall, supplier: supplier1)
      create(:move, :prison_transfer, supplier: supplier2)
      create(:move, :hospital, supplier: supplier2)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'hospital' => 1,
          'prison_transfer' => 1,
          'total' => 2,
        },
      )
    end
  end
end

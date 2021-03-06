# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveType do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_type')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:move, :court_appearance)
      create(:move, :prison_recall)
      create(:move, :hospital)
      create(:move, :hospital)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'court_appearance' => 1,
          'prison_recall' => 1,
          'hospital' => 2,
          'total' => 4,
        },
      )
    end
  end
end

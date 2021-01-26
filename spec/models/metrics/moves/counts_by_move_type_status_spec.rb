# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveTypeStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_type_status')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(:requested) }

    before do
      create(:move, :proposed, :prison_recall)
      create(:move, :requested, :prison_recall)
      create(:move, :requested, :prison_transfer)
      create(:move, :completed, :hospital)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'prison_recall' => 1,
          'prison_transfer' => 1,
          'total' => 2,
        },
      )
    end
  end
end

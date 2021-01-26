# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and Moves modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::Moves)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_status')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:move, :proposed)
      create(:move, :requested)
      create(:move, :requested)
      create(:move, :completed)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'completed' => 1,
          'proposed' => 1,
          'requested' => 2,
          'total' => 4,
        },
      )
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_status')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:person_escort_record)
      create(:person_escort_record, :in_progress)
      create(:person_escort_record, :completed)
      create(:person_escort_record, :confirmed)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'unstarted' => 1,
          'in_progress' => 1,
          'completed' => 1,
          'confirmed' => 1,
          'total' => 4,
        },
      )
    end
  end
end

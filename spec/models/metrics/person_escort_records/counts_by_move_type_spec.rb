# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByMoveType do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_type')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:person_escort_record, move_attr: :court_appearance)
      create(:person_escort_record, move_attr: :prison_recall)
      create(:person_escort_record, move_attr: :hospital)
      create(:person_escort_record, move_attr: :hospital)
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

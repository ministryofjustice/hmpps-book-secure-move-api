# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByMoveTypeMoveStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_type_move_status')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(:requested) }

    before do
      create(:person_escort_record, move_attr: %i[court_appearance requested])
      create(:person_escort_record, move_attr: %i[prison_recall requested])
      create(:person_escort_record, move_attr: %i[court_appearance in_transit])
      create(:person_escort_record, move_attr: %i[prison_recall completed])
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'court_appearance' => 1,
          'prison_recall' => 1,
          'total' => 2,
        },
      )
    end
  end
end

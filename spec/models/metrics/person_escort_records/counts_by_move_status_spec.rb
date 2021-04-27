# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::CountsByMoveStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql('counts_by_move_status')
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:person_escort_record, move_attr: :proposed)
      create(:person_escort_record, move_attr: :requested)
      create(:person_escort_record, move_attr: :booked)
      create(:person_escort_record, move_attr: :in_transit)
      create(:person_escort_record, move_attr: :completed)
      create(:person_escort_record, move_attr: :cancelled)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'proposed' => 1,
          'requested' => 1,
          'booked' => 1,
          'in_transit' => 1,
          'completed' => 1,
          'cancelled' => 1,
          'total' => 6,
        },
      )
    end
  end
end

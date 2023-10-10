# frozen_string_literal: true

require 'rails_helper'

# NB: the mock class name must be unique in test suite
class MockMetricsPersonEscortRecords
  include Metrics::PersonEscortRecords

  attr_reader :supplier

  def initialize(supplier: nil)
    @supplier = supplier
  end
end

RSpec.describe MockMetricsPersonEscortRecords do
  context 'without supplier' do
    describe 'database' do
      subject { described_class.new.database }

      it { is_expected.to eql('person_escort_records') }
    end

    describe 'person_escort_records_with_moves' do
      subject { described_class.new.person_escort_records_with_moves }

      let(:person_escort_records) { create_list(:person_escort_record, 2) }

      before do
        person_escort_records
      end

      it { is_expected.to match_array(person_escort_records) }
    end
  end

  context 'with supplier' do
    let(:supplier) { create(:supplier, key: 'supplier') }

    describe 'database' do
      subject { described_class.new(supplier:).database }

      it { is_expected.to eql('person_escort_records_supplier') }
    end

    describe 'person_escort_records_with_moves' do
      subject { described_class.new(supplier:).person_escort_records_with_moves }

      let(:person_escort_records) { create_list(:person_escort_record, 2, move_attr: [supplier:]) }
      let(:other_person_escort_records) { create_list(:person_escort_record, 2) }

      before do
        person_escort_records
        other_person_escort_records
      end

      it { is_expected.to match_array(person_escort_records) }
    end
  end
end

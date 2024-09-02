# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::PersonEscortRecords::PercentHandoverByLocation do
  subject(:metric) { described_class.new }

  let(:prison) { create(:location, :prison) }
  let(:police) { create(:location, :police) }
  let(:other_prison) { create(:location, :prison, title: 'HMP Other', nomis_agency_id: 'OTHER') }
  let(:yesterday) { Date.yesterday }

  it 'includes the BaseMetric and PersonEscortRecords modules' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
    expect(described_class.ancestors).to include(Metrics::PersonEscortRecords)
  end

  it 'initializes label and file' do
    expect(metric.label).not_to be_nil
    expect(metric.file).to eql("#{yesterday.year}/#{yesterday.month}/#{yesterday.day}/per_handover_by_location")
  end

  describe 'calculate_table' do
    subject(:calculate_table) { metric.calculate_table }

    before do
      create(:person_escort_record, :unstarted, move_attr: [:completed, { date: Date.yesterday, from_location: prison }])
      create(:person_escort_record, :in_progress, move_attr: [:completed, { date: Date.yesterday, from_location: prison }])
      create(:person_escort_record, :completed, move_attr: [:cancelled, { date: Date.yesterday, from_location: prison }])
      create(:person_escort_record, :handover, move_attr: [:completed, { date: Date.yesterday, from_location: prison }])

      create(:person_escort_record, :unstarted, move_attr: [:completed, { date: Date.yesterday, from_location: police }])
      create(:person_escort_record, :completed, move_attr: [:completed, { date: Date.yesterday, from_location: police }])
      create(:person_escort_record, :handover, move_attr: [:completed, { date: Date.yesterday, from_location: police }])
      create(:person_escort_record, :handover, move_attr: [:completed, { date: Date.yesterday, from_location: police }])

      create(:person_escort_record, :handover, move_attr: [:completed, { date: Time.zone.today, from_location: prison }])
      create(:person_escort_record, :handover, move_attr: [:completed, { date: Date.tomorrow, from_location: police }])
      create(:move, :completed, from_location: other_prison)
    end

    it { expect(calculate_table["location__#{prison.nomis_agency_id}"]).to eql prison.title }
    it { expect(calculate_table["type__#{prison.nomis_agency_id}"]).to eql 'prison' }
    it { expect(calculate_table["number_of_PERs__#{prison.nomis_agency_id}"]).to be 4 }
    it { expect(calculate_table["handover_percent__#{prison.nomis_agency_id}"]).to eql '25.0%' }

    it { expect(calculate_table["location__#{police.nomis_agency_id}"]).to eql police.title }
    it { expect(calculate_table["type__#{police.nomis_agency_id}"]).to eql 'police' }
    it { expect(calculate_table["number_of_PERs__#{police.nomis_agency_id}"]).to be 4 }
    it { expect(calculate_table["handover_percent__#{police.nomis_agency_id}"]).to eql '50.0%' }

    it { expect(calculate_table["location__#{other_prison.nomis_agency_id}"]).to eql other_prison.title }
    it { expect(calculate_table["type__#{other_prison.nomis_agency_id}"]).to eql 'prison' }
    it { expect(calculate_table["number_of_PERs__#{other_prison.nomis_agency_id}"]).to be 0 }
    it { expect(calculate_table["handover_percent__#{other_prison.nomis_agency_id}"]).to be_nil }
  end
end

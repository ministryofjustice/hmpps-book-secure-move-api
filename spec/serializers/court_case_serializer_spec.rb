# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtCaseSerializer do
  subject(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  let(:serializer) { described_class.new(court_case) }

  let(:court_case) do
    CourtCase.new.build_from_nomis(
      'id' => '111',
      'caseSeq' => '1',
      'beginDate' => '2016-11-14',
      'caseType' => 'Adult',
      'caseInfoNumber' => 'T20167984',
      'caseStatus' => 'ACTIVE',
      'agency' => { 'agencyId' => location.nomis_agency_id },
    )
  end

  let(:location) { create :location, nomis_agency_id: 'SNARCC' }

  it 'return a serialized court cases' do
    expect(result[:data][:attributes]).to eq(
      nomis_case_id: '111',
      nomis_case_status: 'ACTIVE',
      case_start_date: '2016-11-14',
      case_type: 'Adult',
      case_number: 'T20167984',
    )
  end

  it 'includes related location' do
    expect(result[:data][:relationships][:location][:data]).not_to be_nil
  end
end

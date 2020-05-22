# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtCaseSerializer do
  subject(:court_case_deserialized) { ActiveModelSerializers::Adapter.create(court_case_serializer).serializable_hash }

  let(:court_case_serializer) { described_class.new(court_case) }

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
    expect(court_case_deserialized[:data][:attributes]).to eq(
      nomis_case_id: '111',
      nomis_case_status: 'ACTIVE',
      case_start_date: '2016-11-14',
      case_type: 'Adult',
      case_number: 'T20167984',
    )
    expect(court_case_deserialized[:data][:relationships][:location][:data]).not_to be_nil
  end
end

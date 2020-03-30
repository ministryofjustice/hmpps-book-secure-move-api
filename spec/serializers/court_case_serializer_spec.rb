# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourtCaseSerializer do
  subject(:court_case_deserialized) { ActiveModelSerializers::Adapter.create(court_case_serializer).serializable_hash }

  let(:court_case_serializer) { described_class.new(court_case) }

  let(:court_case) {
    CourtCase.new.build_from_nomis('caseSeq' => '1',
                                   'beginDate' => '2016-11-14',
                                   'caseType' => 'Adult',
                                   'caseInfoNumber' => 'T20167984',
                                   'caseStatus' => 'ACTIVE')
  }

  it 'return a serialized court cases' do
    expect(court_case_deserialized[:data][:attributes]).to eq(nomis_case_id: 'T20167984',
                                                              nomis_case_status: 'ACTIVE',
                                                              nomis_case_start_date: '2016-11-14',
                                                              nomis_case_type: 'Adult',
                                                              nomis_case_number: 'T20167984')
  end
end

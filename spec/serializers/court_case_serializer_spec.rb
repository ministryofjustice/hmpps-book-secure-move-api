# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FastJsonapi::CourtCaseSerializer do
  subject(:court_case_deserialized) { described_class.new(court_case, options).serializable_hash }

  let(:court_case) {
    CourtCase.new.build_from_nomis('id' => '111',
                                   'caseSeq' => '1',
                                   'beginDate' => '2016-11-14',
                                   'caseType' => 'Adult',
                                   'caseInfoNumber' => 'T20167984',
                                   'caseStatus' => 'ACTIVE',
                                   'agency' => { 'agencyId' => location.nomis_agency_id })
  }

  let(:options) { { include: [:location] } }

  let(:location) { create :location, nomis_agency_id: 'SNARCC' }

  it 'return a serialized court cases' do
    expected = {
      data: {
        id: '111',
        type: :court_cases,
        attributes: {
          case_type: 'Adult',
          nomis_case_id: '111',
          nomis_case_status: 'ACTIVE',
          case_start_date: '2016-11-14',
          case_number: 'T20167984',
        },
        relationships: {
          location: {
            data: {
              id: location.id,
              type: :locations,
            },
          },
        },
      },
      included: [
        {
          type: :locations,
          attributes: {
            can_upload_documents: false,
            disabled_at: nil,
            key: location.key,
            location_type: 'prison',
            nomis_agency_id: 'SNARCC',
            title: location.title,
            suppliers: [],
          },
          id: location.id,
        },
      ],
    }
    expect(court_case_deserialized).to eq(expected)
  end
end

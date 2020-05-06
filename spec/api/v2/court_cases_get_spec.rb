require 'rails_helper'

RSpec.describe Api::V2::CourtCases do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe 'GET /api/court_cases' do
    subject(:response) { get "/api/v2/people/#{person.id}/court_cases" }

    before do
      allow(People::RetrieveCourtCases).to receive(:call).and_return(court_cases_from_nomis)
    end

    let(:person) { create(:person) }
    let(:court_cases_from_nomis) {
      OpenStruct.new(
        success?: true,
        court_cases: [
          build_nomis_court_case('12345', '2020-01-02'),
          build_nomis_court_case('12346', '2020-01-03'),
        ],
      )
    }
    let(:serialized_court_cases) do
      FastJsonapi::CourtCaseSerializer.new(
        court_cases_from_nomis.court_cases, include: [:location]
      ).serialized_json
    end

    it { expect(response.status).to eq(200) }
    it { expect(response.body).to eq(serialized_court_cases) }
    it { expect(response.headers).to include('Content-Type' => 'application/vnd.api+json') }
  end

  def build_nomis_court_case(id, begin_date)
    CourtCase.new.build_from_nomis(
      'id' => id,
      'beginDate' => begin_date,
      'agency' => { 'agencyId' => 'SNARCC' },
    )
  end
end

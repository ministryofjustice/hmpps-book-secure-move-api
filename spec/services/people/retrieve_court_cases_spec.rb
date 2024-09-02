# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveCourtCases do
  let(:person) { instance_double(Person, latest_nomis_booking_id: '12345') }
  let(:response_body) { file_fixture('nomis/get_court_cases_200.json').read }
  let(:filter_params) { double }

  before do
    class_double(NomisClient::CourtCases, get: response_body).as_stubbed_const
  end

  it 'returns an array of CourtCase' do
    court_cases_response = described_class.call(person, filter_params)

    expect(court_cases_response.court_cases).to all(be_a(CourtCase))
  end
end

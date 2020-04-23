# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveCourtHearings do
  let(:person) { instance_double('Person', latest_nomis_booking_id: '12345') }
  let(:response_json) { JSON.parse(file_fixture('nomis_get_court_hearings_page_1_200.json').read)["hearings"] }

  before do
    allow(NomisClient::CourtHearings).to receive(:get).and_return(response_json)
  end

  it 'returns an array of CourtHearings' do
    response = described_class.call(person)

    expect(response).to all(be_a(NomisCourtHearing))
  end

  it 'calls NomisClient::CourtHearings with the correct args' do
    described_class.call(person)

    expect(NomisClient::CourtHearings).to have_received(:get).with('12345')
  end
end

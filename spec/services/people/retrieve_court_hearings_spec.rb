# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::RetrieveCourtHearings do
  let(:person) { instance_double('Person', latest_nomis_booking_id: '12345') }
  let(:response_json) { JSON.parse(file_fixture('nomis/get_court_hearings_200.json').read) }
  let(:date_from) { Time.zone.today }
  let(:date_to) { Date.tomorrow }

  context 'when calling to Nomis succeeds' do
    before do
      allow(NomisClient::CourtHearings).to receive(:get).and_return(response_json)
    end

    it 'returns a struct containing CourtHearings' do
      struct = described_class.call(person, date_from, date_to)

      expect(struct.content).to all(be_a(NomisCourtHearing))
    end

    it 'returns a struct indicating calling to Nomis succeeded' do
      struct = described_class.call(person, date_from, date_to)

      expect(struct).to be_success
    end

    it 'calls NomisClient::CourtHearings with the correct booking id' do
      described_class.call(person, date_from, date_to)

      expect(NomisClient::CourtHearings).to have_received(:get).with('12345', date_from, date_to)
    end
  end

  context 'when calling to Nomis fails' do
    before do
      allow(NomisClient::CourtHearings).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
    end

    let(:oauth2_response) do
      instance_double('OAuth2::Response', body: '{}', parsed: {}, status: '')
    end

    it 'returns a struct indicating calling to Nomis failed' do
      struct = described_class.call(person, date_from, date_to)

      expect(struct).not_to be_success
      expect(struct.error).to be_a(NomisClient::ApiError)
    end
  end
end

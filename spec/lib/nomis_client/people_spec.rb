# frozen_string_literal: true

require 'rails_helper'
require 'nomis_client'
require 'nomis_client/moves'
require 'dotenv/load'

RSpec.describe NomisClient::People do
  describe '.get' do
    let(:json_response) do
      <<-JSON
      [
        {
          "offenderNo": "A1378MN",
          "firstName": "Mina",
          "middleNames": "Hope",
          "lastName": "Kunde",
          "dateOfBirth": "1965-04-18",
          "gender": "Female",
          "sexCode": "M",
          "nationalities": "American",
          "currentlyInPrison": "Y",
          "latestBookingId": 1234567,
          "latestLocationId": "WLI",
          "latestLocation": "WAYLAND (HMP)",
          "internalLocation": "ABC-D-1-23",
          "pncNumber": "54/978136W",
          "croNumber": "52731/51W",
          "ethnicity": "Asian/Asian British: Bangladeshi",
          "birthCountry": "Romania",
          "religion": "Roman Catholic",
          "convictedStatus": "Convicted",
          "imprisonmentStatus": "LR",
          "receptionDate": null,
          "maritalStatus": "Married or in civil partnership"
        }
      ]
      JSON
    end
    let(:nomis_response) { instance_double('response', parsed: JSON.parse(json_response)) }
    let(:nomis_offender_number) { 'A1378MN' }
    let(:response) { described_class.get(nomis_offender_number: nomis_offender_number) }

    before do
      allow(NomisClient::Base).to(
        receive(:get)
        .with('/prisoners/A1378MN', params: {}, headers: { 'Page-Limit' => '1000' })
        .and_return(nomis_response)
      )
    end

    it 'has the correct number of results' do
      expect(response.count).to be 1
    end

    it 'has the has the correct offender number' do
      expect(response.first['offenderNo']).to eq nomis_offender_number
    end

    context 'when in test mode' do
      before do
        allow(File).to receive(:read).and_return(erb_test_fixture)
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('NOMIS_TEST_MODE').and_return('true')
      end

      let(:erb_test_fixture) do
        <<-ERB
        [
          {
            "offenderNo": "A1378MN",
            "firstName": "Mina",
            "middleNames": "Hope",
            "lastName": "Kunde",
            "dateOfBirth": "1965-04-18",
            "gender": "Female",
            "sexCode": "M",
            "nationalities": "American",
            "currentlyInPrison": "Y",
            "latestBookingId": 1234567,
            "latestLocationId": "WLI",
            "latestLocation": "WAYLAND (HMP)",
            "internalLocation": "ABC-D-1-23",
            "pncNumber": "54/978136W",
            "croNumber": "52731/51W",
            "ethnicity": "Asian/Asian British: Bangladeshi",
            "birthCountry": "Romania",
            "religion": "Roman Catholic",
            "convictedStatus": "Convicted",
            "imprisonmentStatus": "LR",
            "receptionDate": null,
            "maritalStatus": "Married or in civil partnership"
          }
        ]
        ERB
      end

      let(:expected_file_name) { "#{NomisClient::Base::FIXTURE_DIRECTORY}/people-A1378MN.json.erb" }
      let(:nomis_offender_number) { 'A1378MN' }

      it 'uses the correct file name' do
        described_class.get(nomis_offender_number: nomis_offender_number)
        expect(File).to have_received(:read).with(expected_file_name)
      end

      it 'does not hit the real API' do
        described_class.get(nomis_offender_number: nomis_offender_number)
        expect(NomisClient::Base).not_to have_received(:get)
      end

      it 'returns the correct data' do
        expect(response.count).to be 1
      end
    end
  end

  describe '.anonymise' do
    before do
      create :location, title: 'PENTONVILLE (HMP)', nomis_agency_id: 'PVI'
      create :location, title: 'LEEDS (HMP)', nomis_agency_id: 'LEI'
      create :location, title: 'MANCHESTER (HMP)', nomis_agency_id: 'MRI'
    end

    KEYS = %i[
      offenderNo firstName middleNames lastName dateOfBirth gender sexCode nationalities
      currentlyInPrison latestBookingId latestLocationId latestLocation internalLocation
      pncNumber croNumber ethnicity birthCountry religion convictedStatus
      imprisonmentStatus maritalStatus
    ].freeze
    let(:anonymised) { described_class.anonymise(nil) }

    KEYS.each do |key|
      it "randomly populates the #{key}" do
        expect(anonymised).to have_key(key)
      end
    end
  end
end

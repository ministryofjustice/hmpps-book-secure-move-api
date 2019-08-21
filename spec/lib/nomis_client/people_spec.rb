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
  end
end

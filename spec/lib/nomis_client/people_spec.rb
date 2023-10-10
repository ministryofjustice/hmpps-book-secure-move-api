# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::People do
  describe '.get_response' do
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
        },
        {
          "offenderNo": "A138MNO",
          "firstName": "John",
          "middleNames": "Little",
          "lastName": "Kunde",
          "dateOfBirth": "1965-04-18",
          "gender": "Male",
          "sexCode": "M",
          "nationalities": "English",
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
        },
        {
          "offenderNo": "A1389MN",
          "firstName": "Julia",
          "middleNames": "Mina",
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
    let(:nomis_offender_numbers) { %w[A1378MN A138MNO A1389MN] }
    let(:response) { described_class.get_response(nomis_offender_numbers:) }

    before do
      allow(NomisClient::Base).to(
        receive(:post)
        .with('/prisoners',
              headers: { 'Page-Limit' => nomis_offender_numbers.size.to_s },
              body: { offenderNos: nomis_offender_numbers }.to_json)
        .and_return(nomis_response),
      )
    end

    it 'has the correct number of results' do
      expect(response.count).to be 3
    end

    it 'has the has the correct offender numbers' do
      expect(response.map { |r| r['offenderNo'] }).to eq nomis_offender_numbers
    end
  end

  describe '.get', with_nomis_client_authentication: true do
    let(:prison_numbers) { %w[G3239GV GV345VG G3325XX] }
    let(:response) { described_class.get(prison_numbers) }
    let(:client_response) do
      [
        {
          prison_number: 'G3239GV',
          last_name: 'ABBELLA',
          first_name: 'AVEILKE',
          middle_names: 'EMMANDA',
          date_of_birth: '1965-10-15',
          aliases: nil,
          pnc_number: '82/18053V',
          cro_number: '018053/82G',
          gender: 'M',
          ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
          nationalities: 'British',
          latest_booking_id: 20_305,
        },
        {
          prison_number: 'GV345VG',
          last_name: 'ABBELLA',
          first_name: 'AVEILKE',
          middle_names: 'EMMANDA',
          date_of_birth: '1965-10-15',
          aliases: nil,
          pnc_number: '82/18053V',
          cro_number: '018053/82G',
          gender: 'M',
          ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
          nationalities: 'British',
          latest_booking_id: 20_305,
        },
        {
          prison_number: 'G3325XX',
          last_name: 'ABBELLA',
          first_name: 'AVEILKE',
          middle_names: 'EMMANDA',
          date_of_birth: '1965-10-15',
          aliases: nil,
          pnc_number: '82/18053V',
          cro_number: '018053/82G',
          gender: 'M',
          ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
          nationalities: 'British',
          latest_booking_id: 20_305,
        },
      ]
    end

    context 'when resources are found' do
      let(:response_status) { 200 }
      let(:response_body) { file_fixture('nomis/post_prisoners_200.json').read }

      it 'returns the correct people data' do
        expect(response).to match_array client_response
      end
    end
  end
end

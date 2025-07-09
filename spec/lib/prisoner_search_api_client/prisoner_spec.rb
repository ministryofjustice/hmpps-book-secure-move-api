# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonerSearchApiClient::Prisoner, :with_hmpps_authentication, :with_prisoner_search_api do
  describe '.get' do
    let(:response) { described_class.get('A1234AA') }
    let(:response_body) { file_fixture('prisoner_search_api/get_prisoner_200.json').read }
    let(:response_status) { 200 }

    let(:expected_response) do
      {
        prison_number: 'A1234AA',
        latest_booking_id: '0001200924',
        last_name: 'Larsen',
        first_name: 'Robert',
        middle_names: 'John James',
        date_of_birth: '1975-04-02',
        aliases: [
          {
            'title' => 'Ms',
            'firstName' => 'Robert',
            'middleNames' => 'Trevor',
            'lastName' => 'Lorsen',
            'dateOfBirth' => '1975-04-02',
            'gender' => 'Male',
            'ethnicity' => 'White : Irish',
            'raceCode' => 'W1',
          },
        ],
        pnc_number: '12/394773H',
        cro_number: '29906/12J',
        gender: 'Female',
        ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
        nationalities: 'Egyptian',
      }
    end

    it 'returns the expected prisoner data' do
      expect(response).to eq(expected_response)
    end
  end

  describe '.get with errors' do
    let(:response) { described_class.get('UN_KNOWN') }
    let(:response_body) { '{}' } # Empty JSON object for 404 response
    let(:response_status) { 404 }

    it 'returns hash with nil values for missing prisoner' do
      expected_empty_response = {
        prison_number: nil,
        latest_booking_id: nil,
        last_name: nil,
        first_name: nil,
        middle_names: nil,
        date_of_birth: nil,
        aliases: nil,
        pnc_number: nil,
        cro_number: nil,
        gender: nil,
        ethnicity: nil,
        nationalities: nil,
      }
      expect(response).to eq(expected_empty_response)
    end
  end

  describe '.get without a prison_number' do
    let(:response) { described_class.get(nil) }

    it 'returns nil' do
      expect(response).to be_nil
    end
  end

  describe '.get with OAuth error' do
    let(:prison_number) { 'A1234AA' }

    it 'returns nil and logs warning' do
      allow(PrisonerSearchApiClient::Base).to receive(:get).and_raise(OAuth2::Error.new('Unauthorized'))
      expect(Rails.logger).to receive(:warn).with(/Failed to fetch prisoner data for A1234AA/)

      response = described_class.get(prison_number)
      expect(response).to be_nil
    end
  end

  describe '.facial_image_exists?' do
    let(:response) { described_class.facial_image_exists?('A1234AA') }
    let(:response_body) { '{"currentFacialImageId": "12345"}' }
    let(:response_status) { 200 }

    it 'returns true when image exists' do
      expect(response).to be true
    end

    context 'with no image' do
      let(:response_body) { '{"currentFacialImageId": null}' }

      it 'returns false' do
        expect(response).to be false
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonerSearchApiClient::PersonalCareNeeds, :with_hmpps_authentication, :with_prisoner_search_api do
  describe '.get' do
    let(:response) { described_class.get(prison_number: 'A1234AA') }
    let(:response_body) { file_fixture('prisoner_search_api/get_personal_care_needs_200.json').read }
    let(:response_status) { 200 }
    let(:expected_response) do
      [
        {
          problem_type: 'MATSTAT',
          problem_code: 'ACCU9',
          problem_status: 'ON',
          problem_description: 'Preg, acc under 9mths',
          commentText: 'Disclosed on arrival',
          start_date: '2010-06-21',
          end_date: '2010-06-21',
        },
      ]
    end

    it 'returns the expected personal care needs data' do
      expect(response).to eq(expected_response)
    end
  end

  describe '.get with errors' do
    let(:response) { described_class.get(prison_number: 'UN_KNOWN') }
    let(:response_body) { '{}' } # Empty JSON object for 404 response
    let(:response_status) { 404 }

    it 'returns empty array for missing prisoner' do
      expect(response).to eq([])
    end
  end

  describe '.get with OAuth error' do
    let(:prison_number) { 'A1234AA' }

    it 'returns empty array and logs warning' do
      allow(PrisonerSearchApiClient::Base).to receive(:get).and_raise(OAuth2::Error.new('Unauthorized'))
      expect(Rails.logger).to receive(:warn).with(/Failed to fetch personal care needs for A1234AA/)

      response = described_class.get(prison_number: prison_number)
      expect(response).to eq([])
    end
  end
end

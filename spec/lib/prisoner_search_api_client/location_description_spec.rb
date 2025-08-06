# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonerSearchApiClient::LocationDescription, :with_hmpps_authentication, :with_location_description_api do
  describe '.get' do
    let(:response) { described_class.get(prison_number: 'A1234AA') }

    let(:response_body) { file_fixture('prisoner_search_api/get_prisoner_200.json').read }

    let(:response_status) { 200 }

    it 'returns the expected locationDescription' do
      expect(response).to eq('Outside - released from Leeds')
    end
  end

  describe '.get with errors' do
    let(:response) { described_class.get(prison_number: 'UN_KNOWN') }

    let(:response_body) { file_fixture('prisoner_search_api/get_prisoner_404.json').read }

    let(:response_status) { 404 }

    it 'returns nil' do
      expect(response).to be_nil
    end
  end

  describe '.get without a prison_number' do
    let(:response) { described_class.get(prison_number: nil) }

    it 'returns nil' do
      expect(response).to be_nil
    end
  end
end

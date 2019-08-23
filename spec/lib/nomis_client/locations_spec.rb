# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Locations, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/agencies' }
    let(:response_status) { 200 }
    let(:response_body) { file_fixture('nomis_get_locations_200.json').read }

    it 'has the correct number of results' do
      expect(response.count).to be 4
    end

    it 'returns the correct data for the first match' do
      expect(response.first)
        .to eq(key: 'abdrct', nomis_agency_id: 'ABDRCT', title: 'Aberdare County Court', location_type: :court)
    end

    it 'does not return locations different from prisons and courts' do
      expect(response.select { |item| item[:nomis_agency_id] == 'ASPAP1' }.count).to be_zero
    end
  end
end

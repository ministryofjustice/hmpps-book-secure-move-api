# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::LocationDetails, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/agencies/prison' }
    let(:response_status) { 200 }
    let(:response_body) { file_fixture('nomis/get_location_details_200.json').read }

    it 'has the correct number of results' do
      expect(response.count).to eq 5
    end

    it 'returns a hash keyed by agency id' do
      expect(response.keys).to match_array(%w[ACI AGI ASI AYI BAI])
    end

    it 'returns correct attributes for each location' do
      expect(response.values.first)
        .to eq(premise: 'HMP ALTCOURSE', locality: 'Fazakerley', city: 'Liverpool', country: 'England', postcode: 'L9 7LH')
    end
  end
end

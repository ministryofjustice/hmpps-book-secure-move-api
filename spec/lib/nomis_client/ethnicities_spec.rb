# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Ethnicities, with_nomis_client_authentication: true do
  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/reference-domains/domains/ETHNICITY' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when a resource is found' do
        let(:response_status) { 200 }
        let(:response_body) { file_fixture('nomis_get_ethnicities_200.json').read }

        it 'has the correct number of results' do
          expect(response_json.count).to be 22
        end

        it 'returns the correct data for the first match' do
          expect(response_json.first.symbolize_keys).to eq(
            activeFlag: 'Y', code: 'A1', description: 'Asian/Asian British: Indian', domain: 'ETHNICITY'
          )
        end
      end
    end
  end
end

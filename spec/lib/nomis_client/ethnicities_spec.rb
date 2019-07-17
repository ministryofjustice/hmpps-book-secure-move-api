# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Ethnicities do
  let(:oauth2_client) { instance_double('OAuth2::Client', client_credentials: client_credentials) }
  let(:client_credentials) { instance_double('OAuth2::Strategy::ClientCredentials', get_token: token) }
  let(:token) do
    instance_double('OAuth2::AccessToken',
      get: oauth2_response,
      expires?: true,
      refresh!: true,
      expires_at: token_expires_at)
  end
  let(:oauth2_response) do
    instance_double(
      'OAuth2::Response',
      body: response_body,
      parsed: response_json,
      status: response_status
    )
  end

  before { allow(OAuth2::Client).to receive(:new).and_return(oauth2_client) }

  after do
    NomisClient.instance_variable_set(:@client, nil)
    NomisClient.instance_variable_set(:@token, nil)
  end

  describe '.get' do
    let(:response) { described_class.get }
    let(:api_endpoint) { '/reference-domains/domains/ETHNICITY' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when a resource is found' do
        let(:response_status) { 200 }
        let(:response_body) { file_fixture('nomis_get_ethnicities_200.json').read }
        let(:response_json) { JSON.parse(response_body) }

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

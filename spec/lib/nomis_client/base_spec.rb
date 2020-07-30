# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Base do
  let(:oauth2_client) { instance_double('OAuth2::Client', client_credentials: client_credentials) }
  let(:client_credentials) { instance_double('OAuth2::Strategy::ClientCredentials', get_token: token) }
  let(:token) do
    instance_double(
      'OAuth2::AccessToken',
      get: oauth2_response,
      post: oauth2_response,
      expires?: true,
      expires_at: token_expires_at,
    )
  end
  let(:oauth2_response) { instance_double('OAuth2::Response', body: response_body, status: response_status) }

  before do
    # NB: the NomisClient uses class methods which persist for lifetime of the test suite and can cause problems; clearing
    # these class instance variables before and after tests helps prevent cross-contamination
    NomisClient::Base.instance_variable_set(:@client, nil)
    NomisClient::Base.instance_variable_set(:@token, nil)

    allow(OAuth2::Client).to receive(:new).and_return(oauth2_client)
  end

  after do
    # NB: the NomisClient uses class methods which persist for lifetime of the test suite and can cause problems; clearing
    # these class instance variables before and after tests helps prevent cross-contamination
    NomisClient::Base.instance_variable_set(:@client, nil)
    NomisClient::Base.instance_variable_set(:@token, nil)
  end

  describe '.get' do
    let(:response) { described_class.get(api_endpoint) }
    let(:api_endpoint) { '/movements/transfers/BXI' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when a resource is found' do
        let(:response_body) { file_fixture('nomis_get_moves_200.json').read }
        let(:response_status) { 200 }

        it 'returns a response object with JSON data in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 200' do
          expect(response.status).to eq 200
        end

        it 'reuses the token on multiple requests' do
          described_class.get(api_endpoint)
          described_class.get(api_endpoint)

          expect(client_credentials).to have_received(:get_token).once
        end
      end

      context 'when a resource is not found' do
        let(:response_body) { file_fixture('nomis_get_prisoner_404.json').read }
        let(:response_status) { 404 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when an unrecoverable error occurrs' do
        let(:response_body) { file_fixture('nomis_get_prisoner_500.json').read }
        let(:response_status) { 500 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 500' do
          expect(response.status).to eq 500
        end
      end
    end

    context 'with an expired token' do
      let(:token_expires_at) { 2.hours.ago.to_i }
      let(:response_body) { '' }
      let(:response_status) { 200 }

      it 'gets a new token' do
        described_class.get(api_endpoint)
        described_class.get(api_endpoint)

        expect(client_credentials).to have_received(:get_token).twice
      end
    end

    context 'with a token about to expire' do
      let(:token_expires_at) { 3.seconds.from_now.to_i }
      let(:response_body) { '' }
      let(:response_status) { 200 }

      it 'gets a new token' do
        described_class.get(api_endpoint)
        described_class.get(api_endpoint)

        expect(client_credentials).to have_received(:get_token).twice
      end
    end
  end

  describe '.post' do
    let(:response) do
      described_class.post(
        api_endpoint,
        body: { offenderNos: %w[G3239GV] }.to_json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      )
    end
    let(:api_endpoint) { '/prisoners' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when a resource is found' do
        let(:response_body) { file_fixture('nomis_post_prisoners_200.json').read }
        let(:response_status) { 200 }

        it 'returns a response object with JSON data in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 200' do
          expect(response.status).to eq 200
        end

        it 'reuses the token on multiple requests' do
          response
          response

          expect(client_credentials).to have_received(:get_token).once
        end
      end

      context 'when a resource is not found' do
        let(:response_body) { file_fixture('nomis_post_prisoners_404.json').read }
        let(:response_status) { 404 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when an unrecoverable error occurrs' do
        let(:response_body) { file_fixture('nomis_post_prisoners_500.json').read }
        let(:response_status) { 500 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 500' do
          expect(response.status).to eq 500
        end
      end
    end

    context 'with an expired token' do
      let(:token_expires_at) { 2.hours.ago.to_i }
      let(:response_body) { '' }
      let(:response_status) { 200 }

      it 'gets a new token' do
        described_class.get(api_endpoint)
        described_class.get(api_endpoint)

        expect(client_credentials).to have_received(:get_token).twice
      end
    end

    context 'with a token about to expire' do
      let(:token_expires_at) { 3.seconds.from_now.to_i }
      let(:response_body) { '' }
      let(:response_status) { 200 }

      it 'gets a new token' do
        described_class.post(api_endpoint)
        described_class.post(api_endpoint)

        expect(client_credentials).to have_received(:get_token).twice
      end
    end
  end
end

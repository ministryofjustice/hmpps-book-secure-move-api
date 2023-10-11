# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NomisClient::Base do
  let(:oauth2_client) { instance_double('OAuth2::Client', client_credentials:) }
  let(:client_credentials) { instance_double('OAuth2::Strategy::ClientCredentials', get_token: token) }
  let(:token) do
    instance_double(
      'OAuth2::AccessToken',
      get: oauth2_response,
      post: oauth2_response,
      put: oauth2_response,
      expires?: true,
      expires_at: token_expires_at,
    )
  end
  let(:oauth2_response) { instance_double('OAuth2::Response', body: response_body, status: response_status) }

  before do
    # NB: the NomisClient uses class methods which persist for lifetime of the test suite and can cause problems; clearing
    # these class instance variables before and after tests helps prevent cross-contamination
    described_class.instance_variable_set(:@client, nil)
    described_class.instance_variable_set(:@token, nil)

    allow(OAuth2::Client).to receive(:new).and_return(oauth2_client)
  end

  after do
    # NB: the NomisClient uses class methods which persist for lifetime of the test suite and can cause problems; clearing
    # these class instance variables before and after tests helps prevent cross-contamination
    described_class.instance_variable_set(:@client, nil)
    described_class.instance_variable_set(:@token, nil)
  end

  describe '.get' do
    let(:response) { described_class.get(api_endpoint) }
    let(:api_endpoint) { '/movements/transfers/BXI' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when a resource is found' do
        let(:response_body) { file_fixture('nomis/get_moves_200.json').read }
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
        let(:response_body) { file_fixture('nomis/get_prisoner_404.json').read }
        let(:response_status) { 404 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when an unrecoverable error occurrs' do
        let(:response_body) { file_fixture('nomis/get_prisoner_500.json').read }
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
        let(:response_body) { file_fixture('nomis/post_prisoners_200.json').read }
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
        let(:response_body) { file_fixture('nomis/post_prisoners_404.json').read }
        let(:response_status) { 404 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when an unrecoverable error occurrs' do
        let(:response_body) { file_fixture('nomis/post_prisoners_500.json').read }
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

  describe '.put' do
    let(:response) do
      described_class.put(
        api_endpoint,
        body: { reasonCode: 'ADMI' }.to_json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      )
    end
    let(:api_endpoint) { '/bookings/12345/prison-to-prison/54321/cancel' }

    context 'with a valid token' do
      let(:token_expires_at) { 1.hour.from_now.to_i }

      context 'when request is valid' do
        let(:response_body) { '' }
        let(:response_status) { 200 }

        it 'returns a response object empty body' do
          expect(response.body).to be_blank
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

      context 'when request is invalid' do
        let(:response_body) { file_fixture('nomis/put_bookings_400.json').read }
        let(:response_status) { 400 }

        it 'returns a response object with JSON data in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 400' do
          expect(response.status).to eq 400
        end
      end

      context 'when a resource is not found' do
        let(:response_body) { file_fixture('nomis/put_bookings_404.json').read }
        let(:response_status) { 404 }

        it 'returns a response object with error message in the body' do
          expect(response.body).to eq response_body
        end

        it 'returns a response object with status 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when an unrecoverable error occurrs' do
        let(:response_body) { file_fixture('nomis/put_bookings_500.json').read }
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

  describe '.token_request' do
    let(:response) { described_class.get(api_endpoint) }
    let(:api_endpoint) { '/movements/transfers/BXI' }
    let(:token_expires_at) { 1.hour.from_now.to_i }

    [
      { error: OAuth2::Error, log_text: 'Nomis OAuth Client Error:' },
      { error: Faraday::ConnectionFailed, log_text: 'Nomis Connection Error:' },
      { error: Faraday::TimeoutError, log_text: 'Nomis Connection Error:' },
    ].each do |error_data|
      context "when an #{error_data[:error]} is raised" do
        let(:response_body) { 'Test error text' }
        let(:response_status) { 500 }
        let(:oauth2_error) { error_data[:error].new(OAuth2::Response.new(Faraday::Response.new)) }

        before do
          allow(oauth2_error).to receive(:message).and_return('Test error text')
          allow(Rails).to receive(:logger).and_return(instance_spy('logger'))
        end

        %i[post put get].each do |method|
          context "when the request type is #{method}" do
            before do
              allow(token).to receive(method).and_raise(oauth2_error)
            end

            it 'logs additional info, describing what the error is' do
              expect { described_class.send(:token_request, method, api_endpoint, {}) }.to raise_exception(oauth2_error)
              expect(Rails.logger).to have_received(:warn).once.with("#{error_data[:log_text]} Test error text")
            end
          end
        end
      end
    end
  end
end

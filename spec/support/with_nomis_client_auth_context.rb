# frozen_string_literal: true

RSpec.shared_context 'with NomisClient authentication', shared_context: :metadata do
  let(:oauth2_client) { instance_double('OAuth2::Client', client_credentials: client_credentials) }
  let(:client_credentials) { instance_double('OAuth2::Strategy::ClientCredentials', get_token: token) }
  let(:response_json) { JSON.parse(response_body) }
  let(:token_expires_at) { 1.hour.from_now.to_i }
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
end

RSpec.configure do |rspec|
  rspec.include_context 'with NomisClient authentication', with_nomis_client_authentication: true
end

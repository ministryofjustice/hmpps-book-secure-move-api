# frozen_string_literal: true

RSpec.shared_context 'with NomisClient authentication', shared_context: :metadata do
  let(:oauth2_client) { instance_double('OAuth2::Client', client_credentials: client_credentials) }
  let(:client_credentials) { instance_double('OAuth2::Strategy::ClientCredentials', get_token: token) }
  let(:response_json) { JSON.parse(response_body) }
  let(:token_expires_at) { 1.hour.from_now.to_i }
  let(:token) do
    instance_double(
      'OAuth2::AccessToken',
      get: oauth2_response,
      post: oauth2_response,
      put: oauth2_response,
      expires?: true,
      refresh!: true,
      expires_at: token_expires_at,
    )
  end
  let(:oauth2_response) do
    instance_double(
      'OAuth2::Response',
      body: response_body,
      parsed: response_json,
      status: response_status,
    )
  end

  let(:response_status) { 200 }
  let(:response_body) { '{}' }

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
end

RSpec.configure do |rspec|
  rspec.include_context 'with NomisClient authentication', with_nomis_client_authentication: true
end

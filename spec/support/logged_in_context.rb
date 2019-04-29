# frozen_string_literal: true

RSpec.shared_context 'logged_in', shared_context: :metadata do
  let(:auth_hash) do
    {
      'provider' => 'nomis_oauth2',
      'uid' => nil,
      'info' => {
        'name' => 'Bob',
        'email' => nil
      },
      'credentials' => {
        'token' => '123456',
        'refresh_token' => '654321',
        'expires_at' => 1_556_528_559,
        'expires' => true
      },
      'extra' => {
        'raw_info' => {
          'username' => 'BOB_GEN',
          'active' => true,
          'name' => 'Bob',
          'authSource' => 'nomis',
          'staffId' => 4567,
          'activeCaseLoadId' => 'HLI'
        }
      }
    }
  end

  before do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(auth_hash)
    get '/auth/nomis_oauth2/callback'
  end

  after do
    # TODO: Logout
    OmniAuth.config.mock_auth[:default] = nil
  end
end

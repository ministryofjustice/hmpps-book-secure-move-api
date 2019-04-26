# frozen_string_literal: true

RSpec.shared_context 'logged_in', shared_context: :metadata do
  let(:auth_hash) do
    {
      'provider' => 'nomis-oauth2',
      'uid' => '123',
      'info' => {
        'name' => 'Bob Roberts'
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /auth/nomis_oauth2/callback' do
    let(:auth_hash) do
      {
        'provider' => 'nomis-oauth2',
        'uid' => '123'
      }
    end
    let(:redirect_url) { '' }

    before do
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(auth_hash)
      get "/auth/nomis_oauth2/new?redirect_url=#{redirect_url}"
      get '/auth/nomis_oauth2/callback'
    end

    it 'adds the current user details to the session' do
      expect(session[:current_user]).to eql auth_hash
    end

    context 'when the redirect url is NOT specified' do
      it 'redirects to root path' do
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when the redirect url is specified' do
      let(:redirect_url) { 'http://example.com/after_login' }

      it 'redirects to given url' do
        expect(response).to redirect_to(redirect_url)
      end
    end
  end
end

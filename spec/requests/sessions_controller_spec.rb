# frozen_string_literal: true

require 'rails_helper'
require 'support/logged_in_context'

RSpec.describe SessionsController, type: :request do
  describe 'GET /auth/nomis_oauth2/new' do
    let(:redirect_url) { 'http://example.com/after_login' }

    before do
      get "/auth/nomis_oauth2/new?redirect_url=#{redirect_url}"
    end

    it 'redirects to the login page' do
      expect(response).to redirect_to('/auth/nomis_oauth2')
    end

    it 'stores the redirect url' do
      expect(session[:post_authentication_redirect_url]).to eq redirect_url
    end
  end

  describe 'GET /auth/nomis_oauth2/callback' do
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

    let(:redirect_url) { '' }
    let(:user_token) { UserToken.last }

    before do
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(auth_hash)
      get "/auth/nomis_oauth2/new?redirect_url=#{redirect_url}"
    end

    context 'when there is no existing UserToken record' do
      it 'creates a new UserToken record' do
        expect { get '/auth/nomis_oauth2/callback' }.to change(UserToken, :count).by(1)
      end

      # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      it 'sets the correct attributes for the new UserToken record' do
        get '/auth/nomis_oauth2/callback'
        expect(user_token.access_token).to eq '123456'
        expect(user_token.refresh_token).to eq '654321'
        expect(user_token.expires_at).to eq Time.utc(2019, 4, 29, 9, 2, 39)
        expect(user_token.user_name).to eq 'Bob'
        expect(user_token.user_id).to eq 'BOB_GEN'
      end
      # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
    end

    context 'when a UserToken record already exists' do
      let!(:user_token) do
        UserToken.create!(
          access_token: '123456',
          refresh_token: '654321',
          expires_at: Time.utc(2019, 4, 29, 9, 2, 39),
          user_name: 'Bob',
          user_id: 'BOB_GEN'
        )
      end

      it 'does NOT create a new UserToken record' do
        expect { get '/auth/nomis_oauth2/callback' }.not_to change(UserToken, :count)
      end

      it 'adds the access token to the session' do
        get '/auth/nomis_oauth2/callback'
        expect(session[:token]).to eql user_token.access_token
      end
    end

    context 'when the redirect url is NOT specified' do
      it 'redirects to root path' do
        get '/auth/nomis_oauth2/callback'
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when the redirect url is specified' do
      let(:redirect_url) { 'http://example.com/after_login' }

      it 'redirects to given url' do
        get '/auth/nomis_oauth2/callback'
        expect(response).to redirect_to(redirect_url)
      end
    end
  end

  describe 'GET /auth/nomis_oauth2/logout' do
    context 'when logged in' do
      include_context 'logged_in'

      before do
        get '/auth/nomis_oauth2/logout'
      end

      it 'redirects to the root URL' do
        expect(response).to redirect_to(root_url)
      end

      it 'removes the session token' do
        expect(session[:token]).to be_nil
      end

      it 'deletes the UserToken record' do
        expect(UserToken.find_by(user_name: user_name)).to be_nil
      end
    end
  end
end

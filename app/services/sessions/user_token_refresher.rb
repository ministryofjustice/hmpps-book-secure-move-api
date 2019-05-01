# frozen_string_literal: true

module Sessions
  class UserTokenRefresher
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def refresh
      token = OAuth2::AccessToken.new(
        oauth2_client,
        current_user.access_token,
        expires_at: current_user.expires_at.to_i,
        refresh_token: current_user.refresh_token
      )
      token.refresh!(
        headers: { 'Authorization' => basic_auth_header }
      )
      current_user.update_attributes!(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at
      )
      current_user
    end

    def oauth2_client
      OAuth2::Client.new(
        ENV['FRONT_END_OAUTH_CLIENT_ID'],
        ENV['FRONT_END_OAUTH_SECRET'],
        site: ENV['FRONT_END_OAUTH_HOST'],
        token_url: "#{ENV['FRONT_END_OAUTH_HOST']}/auth/oauth/token",
        parse_json: true
      )
    end

    def basic_auth_header
      'Basic ' + Base64.strict_encode64("#{ENV['FRONT_END_OAUTH_CLIENT_ID']}:#{ENV['FRONT_END_OAUTH_SECRET']}")
    end
  end
end

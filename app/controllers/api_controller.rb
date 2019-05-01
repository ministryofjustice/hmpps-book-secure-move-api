# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :restrict_content_type
  after_action :set_content_type
  before_action :authenticate_session

  JSON_API_CONTENT_TYPE = 'application/vnd.api+json'

  private

  def restrict_content_type
    return if request.content_type == JSON_API_CONTENT_TYPE

    render(
      json: { errors: [{ title: "Content-Type must be #{JSON_API_CONTENT_TYPE}" }] },
      status: 415
    )
  end

  def set_content_type
    self.content_type = JSON_API_CONTENT_TYPE
  end

  def refresh_token_if_expired
    return if current_user.expires_at > Time.utc.now

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
    self.current_user = current_user
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

  def authenticate_session
    load_current_user
    refresh_token_if_expired if current_user
    return if authenticated?

    render(
      json: { errors: [{ title: 'You must be logged in to use this API' }] },
      status: 401
    )
  end
end

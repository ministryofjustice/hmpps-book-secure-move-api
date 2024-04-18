# frozen_string_literal: true

class HmppsAuthApiController < ApiController
  before_action :verify_token

  API_ROLE = ''

  def current_user
    nil
  end

  def doorkeeper_application_owner
    nil
  end

private

  def authentication_enabled?
    false # bypass doorkeeper auth
  end

  def verify_token
    unless token.valid_token_with_scope?('read', role: API_ROLE)
      render_error('Valid authorisation token required')
    end
  end

  def token
    access_token = parse_access_token(request.headers['AUTHORIZATION'])
    HmppsApi::Oauth::Token.new(access_token:)
  end

  def parse_access_token(auth_header)
    return nil if auth_header.nil?
    return nil unless auth_header.starts_with?('Bearer')

    auth_header.split.last
  end
end

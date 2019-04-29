# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    session[:post_authentication_redirect_url] = params[:redirect_url] if params[:redirect_url].present?
    redirect_to '/auth/nomis_oauth2'
  end

  def create
    self.current_user = auth_hash
    create_user_token
    redirect_to post_authentication_redirect_url
  end

  def destroy
    self.current_user = nil
    redirect_to '/'
  end

  protected

  def post_authentication_redirect_url
    session.delete(:post_authentication_redirect_url) || root_url
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def create_user_token
    UserToken.create!(
      access_token: access_token_from(auth_hash),
      refresh_token: refresh_token_from(auth_hash),
      expires_at: expires_at_from(auth_hash),
      user_name: user_name_from(auth_hash),
      user_id: user_id_from(auth_hash)
    )
  end

  def access_token_from(auth_hash)
    auth_hash['credentials']['token']
  end

  def refresh_token_from(auth_hash)
    auth_hash['credentials']['refresh_token']
  end

  def expires_at_from(auth_hash)
    Time.at(auth_hash['credentials']['expires_at']).utc
  end

  def user_name_from(auth_hash)
    auth_hash['extra']['raw_info']['name']
  end

  def user_id_from(auth_hash)
    auth_hash['extra']['raw_info']['username']
  end
end

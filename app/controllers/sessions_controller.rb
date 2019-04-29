# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    session[:post_authentication_redirect_url] = params[:redirect_url]
    redirect_to '/auth/nomis_oauth2'
  end

  def create
    self.current_user = auth_hash
    redirect_to post_authentication_redirect_url
  end

  def destroy
    self.current_user = nil
    redirect_to '/'
  end

  protected

  def post_authentication_redirect_url
    session.delete(:post_authentication_redirect_url) || root_path
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end

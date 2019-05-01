# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    session[:post_authentication_redirect_url] = params[:redirect_url] if params[:redirect_url].present?
    redirect_to '/auth/nomis_oauth2'
  end

  def create
    self.current_user = Sessions::UserTokenFactory.new(auth_hash).find_or_create
    require 'pry'; binding.pry
    session[:token] = current_user.access_token
    redirect_to post_authentication_redirect_url
  end

  def destroy
    load_current_user
    current_user.destroy!
    self.current_user = nil
    session.delete(:token)
    redirect_to root_url
  end

  protected

  def post_authentication_redirect_url
    session.delete(:post_authentication_redirect_url) || root_url
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end

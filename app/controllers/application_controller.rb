# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_user=(current_user)
    session[:current_user] = current_user
  end

  def current_user
    session[:current_user]
  end

  def load_current_user
    return if current_user

    user_token = UserToken.where(access_token: access_token_from_request).first
    session[:current_user] = user_token if user_token
  end

  def authenticated?
    current_user.present?
  end

  def access_token_from_request
    pattern = /^Bearer /
    header  = request.env['Authorization']
    header.gsub(pattern, '') if header&.match(pattern)
  end

  helper_method :current_user
end

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_accessor :current_user

  def load_current_user
    return current_user if current_user

    user_token = UserToken.where(access_token: access_token_from_request).first
    self.current_user = user_token if user_token
  end

  def authenticated?
    current_user.present?
  end

  def access_token_from_request
    session[:token]
  end

  helper_method :current_user
end

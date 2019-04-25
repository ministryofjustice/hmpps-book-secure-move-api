# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_user=(current_user)
    session[:current_user] = current_user
  end

  def current_user
    session[:current_user]
  end

  helper_method :current_user
end

# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    self.current_user = auth_hash
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

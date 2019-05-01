# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    load_current_user
    render :index
  end
end

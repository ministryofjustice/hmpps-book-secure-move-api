# frozen_string_literal: true

class MovesController < ApplicationController
  def index
    render json: Move.all
  end
end

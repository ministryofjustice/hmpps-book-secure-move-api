# frozen_string_literal: true

class MovesController < ApplicationController
  def index
    render jsonapi: Move.all
  end
end

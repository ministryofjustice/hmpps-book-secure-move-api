# frozen_string_literal: true

class DiagnosticsController < ApplicationController
  before_action :doorkeeper_authorize!, unless: -> { Rails.env.development? }

  def moves
    move = Move.find_by(id: params[:id]) || Move.find_by(reference: params[:id])
    if move.present?
      render plain: Diagnostics::MoveInspector.new(move).generate, status: :ok
    else
      render plain: "Move \"#{params[:id]}\" not found", status: :not_found
    end
  end
end

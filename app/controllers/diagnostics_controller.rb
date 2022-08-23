# frozen_string_literal: true

class DiagnosticsController < ApiController
  def set_content_type
    self.content_type = 'text/plain'
  end

  def move
    move = Move.accessible_by(current_ability).find_by(id: params[:id]) || Move.accessible_by(current_ability).find_by(reference: params[:id])
    # NB: personal details should only be available on localhost, dev, staging and uat; not on pre-prod or production
    include_person_details = Rails.env.development? || ENV.fetch('HOSTNAME', 'UNKNOWN') =~ /(-(dev|staging|uat)-)/i
    include_per_history = params[:include_per_history] == 'true'

    if move.present?
      render plain: Diagnostics::MoveInspector.new(move, include_person_details: include_person_details, include_per_history: include_per_history).generate, status: :ok
    else
      render plain: "Move \"#{params[:id]}\" not found", status: :not_found
    end
  end
end

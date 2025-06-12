# frozen_string_literal: true

class MovesExportEmailWorker
  include Sidekiq::Worker

  def perform(recipient_email, application_id, filter_params, sort_params, active_record_relationships)
    application = Doorkeeper::Application.find(application_id)
    ability = Ability.new(application)

    moves = Moves::Finder.new(
      filter_params: filter_params,
      ability: ability,
      order_params: sort_params,
      active_record_relationships: active_record_relationships,
    ).call

    ReportMailer.with(
      recipient_email: recipient_email,
      moves: moves,
    ).moves_export.deliver_now
  rescue StandardError => e
    Rails.logger.error "MovesExportEmailWorker failed for email #{recipient_email}: #{e.message}"
  end
end

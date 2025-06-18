# frozen_string_literal: true

class MovesExportEmailWorker
  include Sidekiq::Worker

  def perform(recipient_email, move_ids)
    moves = Move.includes(CSV_INCLUDES).where(id: move_ids)

    ReportMailer.with(
      recipient_email: recipient_email,
      moves: moves,
    ).moves_export.deliver_now
  rescue StandardError => e
    Rails.logger.error "MovesExportEmailWorker failed for email #{recipient_email}: #{e.message}"
  end

  CSV_INCLUDES = [:from_location, :to_location, :journeys, :profile, :supplier, { person: %i[gender ethnicity] }].freeze
end

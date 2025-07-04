# frozen_string_literal: true

require 'zip'

class MovesExportEmailWorker
  include Sidekiq::Worker

  CSV_INCLUDES = [
    :from_location,
    :to_location,
    :journeys,
    :profile,
    :supplier,
    { person: %i[gender ethnicity] },
  ].freeze

  def perform(recipient_email, move_ids)
    moves = Move.includes(CSV_INCLUDES).where(id: move_ids)
    csv_tempfile = nil
    zip_tempfile = nil

    begin
      csv_tempfile = Moves::Exporter.new(moves).call
      csv_tempfile.rewind
      csv_content = csv_tempfile.read

      timestamp = Time.current.strftime('%Y-%m-%d_%H-%M')
      csv_filename = "moves_export_#{timestamp}.csv"
      zip_filename = "moves_export_#{timestamp}.zip"

      zip_tempfile = Tempfile.new(['moves_export_zip', '.zip'])

      Zip::File.open(zip_tempfile.path, Zip::File::CREATE) do |zipfile|
        zipfile.add(csv_filename, StringIO.new(csv_content))
      end

      ReportMailer.with(
        recipient_email: recipient_email,
        zip_file_path: zip_tempfile.path,
        filename: zip_filename,
      ).moves_export.deliver_now
    rescue StandardError => e
      Rails.logger.error "MovesExportEmailWorker failed for email #{recipient_email}: #{e.message}"
    ensure
      cleanup_tempfile(csv_tempfile, 'CSV')
      cleanup_tempfile(zip_tempfile, 'ZIP')
    end
  end

private

  def cleanup_tempfile(tempfile, type)
    return unless tempfile

    begin
      tempfile.close unless tempfile.closed?
      File.unlink(tempfile.path) if File.exist?(tempfile.path)
    rescue StandardError => e
      Rails.logger.warn "Failed to clean up #{type} tempfile #{tempfile.path}: #{e.message}"
    end
  end
end

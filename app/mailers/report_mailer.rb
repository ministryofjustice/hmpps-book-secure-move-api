# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # Expects a template with `report-title`, `report-description` and `report-file` personalisations.
  before_action { set_template(ENV.fetch('GOVUK_NOTIFY_REPORT_TEMPLATE_ID')) }

  before_action { @recipients = params[:recipients] }

  default to: -> { @recipients }

  def person_escort_record_quality
    start_date = params[:start_date]
    end_date = params[:end_date]

    csv = Reports::PersonEscortRecordQuality.call(start_date:, end_date:)

    base_filename = "per_quality_report_#{start_date}"
    filename = end_date ? "#{base_filename}_to_#{end_date}.csv" : "#{base_filename}.csv"

    set_personalisation(
      'report-title': 'Person Escort Record Quality',
      'report-description': "#{start_date} - #{end_date}",
      'report-file': Notifications.prepare_upload(StringIO.new(csv), filename:),
    )

    mail
  end

  def moves_export
    recipient_email = params[:recipient_email]
    moves = params[:moves]

    @recipients = [recipient_email]

    timestamp = Time.current.strftime('%Y-%m-%d_%H-%M')
    filename = "moves_export_#{timestamp}.csv"

    csv_tempfile = nil

    begin
      csv_tempfile = Moves::Exporter.new(moves).call
      csv_tempfile.rewind
      csv_content = csv_tempfile.read
      csv_string_io = StringIO.new(csv_content)

      set_personalisation(
        'report-title': 'Moves Export',
        'report-description': "CSV export generated on #{Time.current.strftime('%d/%m/%Y at %H:%M')}",
        'report-file': Notifications.prepare_upload(csv_string_io, filename: filename),
      )

      mail
    ensure
      if csv_tempfile
        begin
          csv_tempfile.close unless csv_tempfile.closed?
          File.unlink(csv_tempfile.path) if File.exist?(csv_tempfile.path)
        rescue StandardError => e
          Rails.logger.warn "Failed to clean up tempfile #{csv_tempfile.path}: #{e.message}"
        end
      end
    end
  end
end

# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # Expects a template with `report-title`, `report-description` and `report-file` personalisations.
  before_action { set_template(ENV.fetch('GOVUK_NOTIFY_REPORT_TEMPLATE_ID')) }

  before_action { @recipients = params[:recipients] }

  default to: -> { @recipients }

  def moves_export
    recipient_email = params[:recipient_email]
    zip_file_path = params[:zip_file_path]
    filename = params[:filename]

    @recipients = [recipient_email]

    # Read the ZIP file created by the worker
    zip_content = File.read(zip_file_path)
    zip_string_io = StringIO.new(zip_content)

    set_personalisation(
      'report-title': 'Moves Export',
      'report-description': "CSV export (zipped) generated on #{Time.current.strftime('%d/%m/%Y at %H:%M')}",
      'report-file': Notifications.prepare_upload(zip_string_io, filename: filename),
    )

    mail
  end
end

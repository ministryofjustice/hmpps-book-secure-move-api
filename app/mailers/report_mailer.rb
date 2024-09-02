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
end

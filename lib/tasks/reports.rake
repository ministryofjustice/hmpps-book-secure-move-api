# frozen_string_literal: true

namespace :reports do
  desc 'Email a CSV file reporting on the quality of person escort records to registered recipients.'
  task person_escort_record_quality: :environment do |_task, _args|
    start_date = Time.zone.today.beginning_of_quarter
    end_date = Time.zone.today.end_of_quarter

    recipients = ENV.fetch('PER_QUALITY_REPORT_RECIPIENTS').split(',')

    ReportMailer.with(
      recipients: recipients,
      start_date: start_date,
      end_date: end_date,
    ).person_escort_record_quality.deliver_later
  end
end

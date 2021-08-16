# frozen_string_literal: true

namespace :reports do
  desc 'Generate a CSV file reporting on the quality of person escort records.'
  task :person_escort_record_quality, %w[start_date end_date] => :environment do |_task, args|
    start_date = Date.parse(args.fetch(:start_date))
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : nil

    Reports::PersonEscortRecordQuality.call(start_date: start_date, end_date: end_date)
  end
end

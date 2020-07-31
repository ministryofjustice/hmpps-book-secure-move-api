require 'csv'
require 'json'
require 'aws-sdk-s3'

namespace :journeys do
  desc 'Exports a JSON report of all journeys'
  task json_report: :environment do
    date = ENV['REPORT_DATE'] || Date.yesterday.to_s
    report_date = Date.parse(date).strftime('%Y/%m/%d')
    report_prefix = Date.parse(date).strftime('%Y-%m-%d')
    bucket_name = ENV['S3_REPORTING_BUCKET_NAME'] || raise('S3_REPORTING_BUCKET_NAME not defined')

    puts report_date
    if Rails.env.development?
      Aws.config.update(
        endpoint: 'http://localhost:4572',
        credentials: Aws::Credentials.new('fakeid', 'fakesecret'),
        region: 'eu-west-2',
        force_path_style: true,
      )
    end

    Supplier.order(:key).each do |supplier|
      filename = "#{report_prefix}-#{supplier.key}.json"
      print "Generating #{filename}..."
      moves = []
      # Only include moves with journeys on them.
      Move
          .where("ID in (select move_id from journeys WHERE supplier_id = '#{supplier.id}')")
          .where("moves.updated_at::date = date '#{report_date}'").find_each(batch_size: 100) do |move|
        journeys = []
        Journey
            .where(move: move)
            .where("state in ('completed','canceled')").default_order.each do |journey|
          journeys << {
            id: journey.id,
            supplier: supplier.key,
            timestamp: journey.client_timestamp.iso8601,
            from: journey.from_location.nomis_agency_id,
            to: journey.to_location.nomis_agency_id,
            vehicle: journey.vehicle.present? ? journey.vehicle['registration'] : nil,
            billable: journey.billable,
            events: journey.events.default_order.map do |event|
              {
                timestamp: event.client_timestamp.iso8601,
                event: event.event_name,
                notes: event.details[:event_params].present? ? event.notes : nil,
                from_location: event.from_location&.nomis_agency_id,
                to_location: event.to_location&.nomis_agency_id,
              }
            end,
          }
        end
        person = move.profile.present? ? move.profile.person : nil
        move_notification = move.notifications.webhooks.where(event_type: 'create_move').order(:delivered_at).first
        moves << {
          id: move.id,
          supplier: supplier.key,
          reference: move.reference,
          notified_at: move_notification&.delivered_at,
          updated_at: move.updated_at,
          move_date: move.date,
          from: move.from_location.nomis_agency_id,
          to: move.to_location&.nomis_agency_id,
          person_id: person&.id,
          pnc_number: person&.police_national_computer,
          prison_id: person&.nomis_prison_number,
          gender: person&.gender&.key,
          dob: person&.date_of_birth,
          age: person.present? && person.date_of_birth.present? ? ((move.date.to_date - person.date_of_birth&.to_date) / 365.25).to_i : nil,
          events: move.move_events.default_order.map do |move_event|
            {
              timestamp: move_event.client_timestamp.iso8601,
              event: move_event.event_name,
              notes: move_event.notes,
              from_location: move_event.from_location&.nomis_agency_id,
              to_location: move_event.to_location&.nomis_agency_id,
            }
          end,
          journeys: journeys,
        }
      end
      print " #{moves.length} moves exported. "
      puts 'done.'

      File.open(filename, 'w') do |file|
        file.write(JSON.pretty_generate({ moves: moves })) # maybe change to .to_json for production
      end

      if bucket_name.present?
        print "Exporting #{report_date}/#{filename} to S3..."
        s3 = Aws::S3::Resource.new
        obj = s3.bucket(bucket_name).object("#{report_date}/#{filename}")
        obj.upload_file(filename)
        puts 'done.'
      else
        puts 'S3_REPORTING_BUCKET_NAME not defined, skipping upload.'
      end
    end
  end
end

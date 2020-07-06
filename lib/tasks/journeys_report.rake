require 'csv'
require 'json'
require 'aws-sdk-s3'

def get_last_run(bucket_name)
  s3 = Aws::S3::Resource.new
  # Amazon S3 lists objects in alphabetical order
  objects = s3.bucket(bucket_name).objects().collect(&:key)
  timestamp = objects.any? ? objects.last.split('/').first : '0'
  DateTime.strptime(timestamp, '%s')
end

namespace :journeys do
  desc 'Exports a JSON report of all journeys'
  task json_report: :environment do
    timestamp = DateTime.now.utc.to_i
    bucket_name = ENV['S3_REPORTING_BUCKET_NAME'] || raise('S3_REPORTING_BUCKET_NAME not defined')

    if Rails.env.development?
      Aws.config.update(
        endpoint: 'http://localhost:4572',
        credentials: Aws::Credentials.new('fakeid', 'fakesecret'),
        region: 'eu-west-2',
        force_path_style: true,
      )
    end

    last_report_date = get_last_run(bucket_name)
    puts last_report_date

    Supplier.order(:key).each do |supplier|
      filename = "#{supplier.key}-#{timestamp}.json"
      puts "Generating #{filename}..."
      moves = []
      # Only include moves with journeys on them.
      Move
          .where("ID in (select move_id from journeys WHERE supplier_id = '#{supplier.id}')")
          .where("moves.updated_at > '#{last_report_date}'")
          .where("moves.updated_at <= '#{Time.at(timestamp).utc}'")
          .order('moves.date ASC, moves.reference ASC').each do |move|
        journeys = []
        Journey.where(move: move).default_order.each do |journey|
          journeys << {
            id: journey.id,
            supplier: supplier.name,
            timestamp: journey.client_timestamp.iso8601,
            from: journey.from_location.nomis_agency_id,
            to: journey.to_location.nomis_agency_id,
            vehicle: journey.vehicle['registration'],
            billable: journey.billable,
            events: journey.events.default_order.map do |event|
              {
                timestamp: event.client_timestamp.iso8601,
                event: event.event_name,
                notes: event.notes,
                from_location: event.from_location&.nomis_agency_id,
                to_location: event.to_location&.nomis_agency_id,
              }
            end,
          }
        end
        moves << {
          id: move.id,
          supplier: supplier.key,
          reference: move.reference,
          created_date: move.created_at.to_date,
          date: move.date,
          from: move.from_location.nomis_agency_id,
          to: move.to_location&.nomis_agency_id,
          person_id: move.profile.person_id,
          gender: move.person.gender&.key,
          dob: move.person.date_of_birth,
          age: ((move.date.to_date - move.profile.person.date_of_birth.to_date) / 365.25).to_i,
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

      File.open(filename, 'w') do |file|
        file.write(JSON.pretty_generate({ moves: moves })) # maybe change to .to_json for production
      end

      if bucket_name.present?
        puts "Exporting #{filename} to S3..."
        s3 = Aws::S3::Resource.new
        obj = s3.bucket(bucket_name).object("#{timestamp}/#{filename}")
        obj.upload_file(filename)
      else
        puts 'S3_REPORTING_BUCKET_NAME not defined, skipping upload.'
      end
    end
  end
end

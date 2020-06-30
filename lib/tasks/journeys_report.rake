require 'csv'
require 'json'
require 'aws-sdk-s3'

namespace :journeys do
  desc 'Exports a JSON report of all journeys'
  task json_report: :environment do
    timestamp = DateTime.now.utc.to_i

    Supplier.order(:key).each do |supplier|
      filename = "#{supplier.key}-#{timestamp}.json"
      puts "Generating #{filename}..."
      moves = []
      Move
          .where("ID in (select move_id from journeys WHERE supplier_id = '#{supplier.id}')")
          .order('moves.date ASC, moves.reference ASC').each do |move|
        journeys = []
        Journey.where(move: move).default_order.each do |journey|
          journeys << {
            timestamp: journey.client_timestamp.strftime('%d/%m %H:%M:%S'),
            from: {
              title: journey.from_location.title,
              id: journey.from_location.id,
              nomis_agency_id: journey.from_location.nomis_agency_id,
            },
            to: {
              title: journey.to_location.title,
              id: journey.to_location.id,
              nomis_agency_id: journey.to_location.nomis_agency_id,
            },
            vehicle: journey.vehicle['registration'],
            billable: journey.billable,
            events: journey.events.default_order.map do |event|
              {
                timestamp: event.client_timestamp.strftime('%d/%m %H:%M:%S'),
                event: event.event_name,
                notes: event.notes,
                from_location: event.from_location&.title,
                to_location: event.to_location&.title,
              }
            end,
          }
        end
        moves << {
          supplier: supplier.key,
          reference: move.reference,
          request_date: move.created_at,
          date: move.date,
          from: move.from_location.key,
          to: move.to_location&.key,
          person_id: move.profile.id,
          dob: move.profile.person.date_of_birth,
          age: ((move.date.to_date - move.profile.person.date_of_birth.to_date) / 365.25).to_i,
          # age: move.date.year - move.profile.person.date_of_birth.year - ((move.date.month > move.profile.person.date_of_birth.month || (move.date.month == move.profile.person.date_of_birth.month && move.date.day >= move.profile.person.date_of_birth.day)) ? 0 : 1),
          events: move.move_events.default_order.map do |move_event|
            {
              timestamp: move_event.client_timestamp.strftime('%d/%m %H:%M:%S'),
              event: move_event.event_name,
              notes: move_event.notes,
              from_location: move_event.from_location&.title,
              to_location: move_event.to_location&.title,
            }
          end,
          journeys: journeys,
        }
      end

      File.open(filename, 'w') do |file|
        file.write(JSON.pretty_generate({ moves: moves })) # maybe change to .to_json for production
      end

      puts "Exporting #{filename} to S3..."
      bucket_name = ENV['S3_REPORTING_BUCKET_NAME']
      if bucket_name.present?
        s3 = Aws::S3::Resource.new
        obj = s3.bucket(bucket_name).object(filename)
        obj.upload_file(filename)
      else
        puts 'S3_REPORTING_BUCKET_NAME not defined, skipping upload.'
      end
    end
  end
end

require 'csv'
require 'json'
namespace :journeys do
  desc 'Exports a CSV report of all journeys'
  task csv_report: :environment do
    puts 'exporting journeys_report.csv...'

    CSV.open('journeys_report.csv', 'w') do |csv|
      csv << ['SUPPLIER', 'DATE', 'MOVE REFERENCE', 'MOVE FROM', 'MOVE TO', 'MOVE EVENTS', 'TIMESTAMP', 'JOURNEY FROM (title)', 'JOURNEY FROM (nomis id)', 'JOURNEY TO (title)', 'JOURNEY TO (nomis id)', 'JOURNEY EVENTS', 'VEHICLE', 'BILLABLE']

      current_reference = nil
      Journey
          .joins(:move).includes(:move)
          .joins(:supplier).includes(:supplier)
          .joins(:from_location).includes(:from_location)
          .joins(:to_location).includes(:to_location)
          .order('suppliers.key ASC, moves.date ASC, moves.reference ASC, journeys.client_timestamp ASC')
          .each do |journey| # NB: cannot do find_each because we need to order
        csv << if current_reference != journey.move.reference
                 # new move
                 [journey.supplier.key,
                  journey.move.date,
                  journey.move.reference,
                  journey.move.from_location.title,
                  journey.move.to_location&.title,
                  journey.move.move_events.map { |event| "#{event.event_name}: #{event.notes}" }.join('; '),
                  journey.client_timestamp.strftime('%d/%m %H:%M:%S'),
                  journey.from_location.title,
                  journey.from_location.nomis_agency_id,
                  journey.to_location.title,
                  journey.to_location.nomis_agency_id,
                  journey.events.map { |event| "#{event.event_name}: #{event.notes}" }.join('; '),
                  journey.vehicle['registration'],
                  journey.billable]
               else
                 # journey within current move
                 [nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  nil,
                  journey.client_timestamp.strftime('%d/%m %H:%M:%S'),
                  journey.from_location.title,
                  journey.from_location.nomis_agency_id,
                  journey.to_location.title,
                  journey.to_location.nomis_agency_id,
                  journey.events.map { |event| "#{event.event_name}: #{event.notes}" }.join('; '),
                  journey.vehicle['registration'],
                  journey.billable]
               end
        current_reference = journey.move.reference
      end
    end
  end

  desc 'Exports a JSON report of all journeys'
  task json_report: :environment do
    puts 'exporting journeys_report.json...'

    suppliers = []
    Supplier.order(:key).each do |supplier|
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
          reference: move.reference,
          date: move.date,
          from: move.from_location.title,
          to: move.to_location&.title,
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
      suppliers << {
        supplier: supplier.key,
        moves: moves,
      }
    end
    File.open('journeys_report.json', 'w') do |file|
      file.write(JSON.pretty_generate({ data: suppliers }))
    end
  end
end

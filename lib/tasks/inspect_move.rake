# frozen_string_literal: true

namespace :inspect do
  desc 'Inspects a move, rake inspect:move '
  task :move, [:id_or_ref] => :environment do |_, args|
    abort "Please specify a move id or move reference, e.g. $ rake 'inspect:move[ABC1234X]'" if args[:id_or_ref].blank?
    move = Move.find_by(id: args[:id_or_ref]) || Move.find_by(reference: args[:id_or_ref])
    abort "Could not find move record with id or reference: #{args[:id_or_ref]}" if move.blank?

    puts 'MOVE RECORD'
    puts '-----------'
    puts "id:\t\t#{move.id}"
    puts "reference:\t#{move.reference}"
    puts "date:\t\t#{move.date}"
    puts "date-from:\t#{move.date_from}" if move.date_from.present?
    puts "date-to:\t#{move.date_to}" if move.date_to.present?
    puts "time due:\t#{move.time_due}" if move.time_due.present?
    puts "status:\t\t#{move.status}"
    if move.cancelled?
      puts "cancel reason:\t#{move.cancellation_reason}"
      puts "cancel comment:\t#{move.cancellation_reason_comment}"
    end
    puts "move type:\t#{move.move_type}"
    puts "from location:\t#{move.from_location&.title}"
    puts "to location:\t#{move.to_location&.title}"
    puts "created at:\t#{move.created_at}"
    puts "updated at:\t#{move.created_at}"
    puts "additional information: #{move.additional_information}"

    puts "\n"
    puts 'MOVE EVENTS'
    puts '-----------'
    if move.move_events.any?
      puts "EVENT\t\tTIMESTAMP\t\t\tPARAMS"
      move.move_events.default_order.each do |event| # NB use each to preserve sort order
        puts "#{event.event_name.ljust(15, ' ')}\t#{event.client_timestamp}\t#{event.event_params}"
      end
    else
      puts '(no events recorded)'
    end

    puts "\n"
    puts 'JOURNEYS'
    puts '--------'
    if move.journeys.any?
      puts "ID\t\t\t\t\tTIMESTAMP\t\t\tSTATE\t\tFROM --> TO"
      move.journeys.default_order.each do |journey| # NB use each to preserve sort order
        puts "#{journey.id}\t#{journey.client_timestamp}\t#{journey.state}\t#{journey.from_location.title} --> #{journey.to_location.title}"
      end
    else
      puts '(no events recorded)'
    end

    puts "\n"
    puts 'JOURNEY EVENTS'
    puts '--------------'
    if move.journeys.any?
      move.journeys.default_order.each do |journey| # NB use each to preserve sort order
        puts "#{journey.from_location.title} --> #{journey.to_location.title} (#{journey.id})"
        if journey.events.any?
          puts "\s\sEVENT\t\t\tTIMESTAMP\t\t\tPARAMS"
          journey.events.default_order.each do |event| # NB use each to preserve sort order
            puts "\s\s#{event.event_name.ljust(15, ' ')}\t#{event.client_timestamp}\t#{event.event_params}"
          end
        else
          puts "\s\s(no events recorded)"
        end
        puts ''
      end
    end
  end
end

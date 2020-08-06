module Diagnostics
  class MoveInspector
    attr_reader :move

    def initialize(move)
      @move = move
    end

    def generate
      @output = <<~ENDREF
        MOVE RECORD
        -----------
        id:\t#{move.id}
        reference:\t#{move.reference}
        date:\t#{move.date}
      ENDREF
      @output << "date-from:\t#{move.date_from}\n" if move.date_from.present?
      @output << "date-to:\t#{move.date_to}\n" if move.date_to.present?
      @output << "time due:\t#{move.time_due}\n" if move.time_due.present?
      @output << "status:\t\t#{move.status}\n"
      @output << "cancel reason:\t#{move.cancellation_reason}\n" if move.cancellation_reason.present?
      @output << "cancel comment:\t#{move.cancellation_reason_comment}\n" if move.cancellation_reason_comment.present?
      @output << <<~ENDDETAILS
        move type:\t#{move.move_type}
        from location:\t#{move.from_location&.title}
        to location:\t#{move.to_location&.title}
        created at:\t#{move.created_at}
        updated at:\t#{move.created_at}
        additional information: #{move.additional_information}
        
        MOVE EVENTS
        -----------
      ENDDETAILS

      if move.move_events.any?
        @output << "EVENT\t\tTIMESTAMP\t\t\tPARAMS\n"
        move.move_events.default_order.each do |event| # NB use each to preserve sort order
          @output << "#{event.event_name.ljust(15)}\t#{event.client_timestamp}\t#{event.event_params}\n"
        end
      else
        @output << "(no events recorded)\n"
      end

      @output << <<~ENDJOURNEYS

        JOURNEYS
        --------
      ENDJOURNEYS

      if move.journeys.any?
        @output << "ID\t\t\t\t\tTIMESTAMP\t\t\tSTATE\t\tFROM --> TO\n"
        move.journeys.default_order.each do |journey| # NB use each to preserve sort order
          @output << "#{journey.id}\t#{journey.client_timestamp}\t#{journey.state}\t#{journey.from_location.title} --> #{journey.to_location.title}\n"
        end
      else
        @output << "(no journeys recorded)\n"
      end

      @output << <<~ENDEVENTS

        JOURNEY EVENTS
        --------------
      ENDEVENTS
      if move.journeys.any?
        move.journeys.default_order.each do |journey| # NB use each to preserve sort order
          @output << "#{journey.from_location.title} --> #{journey.to_location.title} (#{journey.id})\n"
          if journey.events.any?
            @output << "\s\sEVENT\t\t\tTIMESTAMP\t\t\tPARAMS\n"
            journey.events.default_order.each do |event| # NB use each to preserve sort order
              @output << "  #{event.event_name.ljust(15, ' ')}\t#{event.client_timestamp}\t#{event.event_params}\n"
            end
          else
            @output << "  (no events recorded)\n"
          end
          @output << "\n"
        end
      else
        @output << "(no journeys recorded)\n"
      end

      @output
    end
  end
end

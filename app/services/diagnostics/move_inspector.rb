module Diagnostics
  class MoveInspector
    attr_reader :move, :include_person_details

    def initialize(move, include_person_details: false)
      @move = move
      @include_person_details = include_person_details
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
      @output << "cancel comment:\t#{move.cancellation_reason_comment}\n" if include_person_details && move.cancellation_reason_comment.present?
      @output << <<~ENDDETAILS
        move type:\t#{move.move_type}
        from location:\t#{move.from_location&.title}
        to location:\t#{move.to_location&.title}
        supplier:\t#{move.supplier&.name}
        created at:\t#{move.created_at}
        updated at:\t#{move.updated_at}
      ENDDETAILS
      @output << "additional information: #{move.additional_information}" if include_person_details
      @output << <<~ENDMOVEEVENTS

        MOVE EVENTS
        -----------
      ENDMOVEEVENTS

      if move.generic_events.any?
        @output << "#{'EVENT'.ljust(30)}\t#{'TIMESTAMP'.ljust(27)}\t#{'NOTES'.ljust(30)}\tDETAILS\n"
        move.generic_events.applied_order.each do |event| # NB use each to preserve sort order
          # NB only show event params if include_person_details==true, as they could contain personal details
          @output << "#{event.type.ljust(30)}\t#{event.occurred_at.to_s.ljust(27)}\t#{include_person_details ? event.notes.to_s.truncate(30).ljust(30) : '-'.ljust(30)}\t#{include_person_details ? event.details : '-'}\n"
        end
      else
        @output << "(no events recorded)\n"
      end

      @output << <<~ENDJOURNEYS

        JOURNEYS
        --------
      ENDJOURNEYS

      if move.journeys.any?
        @output << "#{'ID'.ljust(37)}\t#{'TIMESTAMP'.ljust(27)}\t#{'STATE'.ljust(12)}\t#{'BILLABLE'.ljust(9)}\t#{'SUPPLIER'.ljust(9)}\tFROM --> TO\n"
        move.journeys.default_order.each do |journey| # NB use each to preserve sort order
          @output << "#{journey.id.to_s.ljust(37)}\t#{journey.client_timestamp.to_s.ljust(27)}\t#{journey.state.to_s.ljust(12)}\t#{journey.billable.to_s.ljust(9)}\t#{journey.supplier.name.ljust(9)}\t#{journey.from_location.title} --> #{journey.to_location.title}\n"
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
          if journey.generic_events.any?
            @output << "  #{'EVENT'.ljust(30)}\t#{'TIMESTAMP'.ljust(27)}\t#{'NOTES'.ljust(30)}\tDETAILS\n"
            journey.generic_events.applied_order.each do |event| # NB use each to preserve sort order
              # NB only show event params if include_person_details==true, as they could contain personal details
              @output << "  #{event.type.ljust(30)}\t#{event.occurred_at.to_s.ljust(27)}\t#{include_person_details ? event.notes.to_s.truncate(30).ljust(30) : '-'.ljust(30)}\t#{include_person_details ? event.details : '-'}\n"
            end
          else
            @output << "  (no events recorded)\n"
          end
          @output << "\n"
        end
      else
        @output << "(no journeys recorded)\n"
      end

      @output << <<~WEBHOOKS

        WEBHOOK NOTIFICATIONS
        ---------------------
      WEBHOOKS
      if move.notifications.webhooks.any?
        @output << "#{'TYPE'.ljust(18)}\t#{'DELIVERED AT'.ljust(27)}\t#{'ATTEMPTS'.ljust(9)}\tENDPOINT\n"
        move.notifications.webhooks.order(:created_at).each do |notification|
          @output << "#{notification.event_type.ljust(18)}\t#{notification.delivered_at.to_s.ljust(27)}\t#{notification.delivery_attempts.to_s.ljust(9)}\t#{notification.subscription.callback_url}\n"
        end
      else
        @output << "(no notifications recorded)\n"
      end

      @output << <<~EMAILS

        EMAIL NOTIFICATIONS
        -------------------
      EMAILS
      if move.notifications.emails.any?
        @output << "#{'TYPE'.ljust(18)}\t#{'DELIVERED AT'.ljust(27)}\t#{'ATTEMPTS'.ljust(9)}\tEMAIL\n"
        move.notifications.emails.order(:created_at).each do |notification|
          @output << "#{notification.event_type.ljust(18)}\t#{notification.delivered_at.to_s.ljust(27)}\t#{notification.delivery_attempts.to_s.ljust(9)}\t#{notification.subscription.email_address}\n"
        end
      else
        @output << "(no notifications recorded)\n"
      end

      if include_person_details
        @output << <<~PERSONDETAILS

          PERSON
          ------
        PERSONDETAILS

        if @move.person.present?

          @output << "id:\t#{move.person.id}\n"
          @output << "first names:\t#{move.person.first_names}\n"
          @output << "last name:\t#{move.person.last_name}\n"
          @output << "gender:\t#{move.person.gender&.title}\n"
          @output << "ethnicity:\t#{move.person.ethnicity&.title}\n"
          @output << "date of birth:\t#{move.person.date_of_birth}\n"
          @output << "PN number:\t#{move.person.prison_number}\n"
          @output << "PNC number:\t#{move.person.police_national_computer}\n"
          @output << "CRO number:\t#{move.person.criminal_records_office}\n"
          @output << "created at:\t#{move.person.created_at}\n"
          @output << "updated at:\t#{move.person.updated_at}\n"
        else
          @output << "(no person associated with move)\n"
        end

        @output << <<~PROFILEDETAILS

          PROFILE
          -------
        PROFILEDETAILS

        if @move.profile.present?

          @output << "id:\t#{move.profile.id}\n"
          @output << "created at:\t#{move.profile.created_at}\n"
          @output << "updated at:\t#{move.profile.updated_at}\n"

          @output << "\nASSESSMENT ANSWERS\n"
          @output << "------------------\n"
          if move.profile.assessment_answers.any?
            move.profile.assessment_answers.each do |answer|
              @output << "title:\t#{answer.title}\n"
              @output << "key:\t#{answer.key}\n"
              @output << "category:\t#{answer.category}\n"
              @output << "comments:\t#{answer.comments}\n"
              @output << "created at:\t#{answer.created_at}\n"
              @output << "expires at:\t#{answer.expires_at}\n"
              @output << "nomis_alert_type:\t#{answer.nomis_alert_type}\n"
              @output << "nomis_alert_code:\t#{answer.nomis_alert_code}\n"
              @output << "nomis_alert_type_description:\t#{answer.nomis_alert_type_description}\n"
              @output << "nomis_alert_description:\t#{answer.nomis_alert_description}\n"
              @output << "imported_from_nomis:\t#{answer.imported_from_nomis}\n"
              @output << "---\n"
            end
          else
            @output << "(no assessment answers recorded)\n"
          end
        else
          @output << "(no profile associated with move)\n"
        end
      end

      @output
    end
  end
end

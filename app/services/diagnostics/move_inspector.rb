class Diagnostics::MoveInspector
  attr_reader :move, :include_person_details, :include_per_history

  def initialize(move, include_person_details: false, include_per_history: false)
    @move = move
    @include_person_details = include_person_details
    @include_per_history = include_per_history
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
    @output << "status:\t#{move.status}\n"
    @output << "move type:\t#{move.move_type}\n"
    @output << "cancel reason:\t#{move.cancellation_reason}\n" if move.cancellation_reason.present?
    @output << "cancel comment:\t#{move.cancellation_reason_comment}\n" if include_person_details && move.cancellation_reason_comment.present?
    @output << "prison transfer reason:\t#{move.prison_transfer_reason.title}\n" if include_person_details && move.prison_transfer_reason.present?
    @output << "prison transfer comment:\t#{move.reason_comment}\n" if include_person_details && move.reason_comment.present?
    @output << "from location:\t#{move.from_location}\n"

    if move.versions.many?
      move.versions.where.not(object: nil).first.reify.to_location.tap do |original_to_location|
        @output << "original to location:\t#{original_to_location}\n" if original_to_location != move.to_location
      end
    end

    @output << <<~ENDDETAILS
      to location:\t#{move.to_location}
      supplier:\t#{move.supplier&.name}
      created at:\t#{move.created_at}
      updated at:\t#{move.updated_at}
    ENDDETAILS
    @output << "additional information: #{move.additional_information}\n" if include_person_details

    if move.allocation.present?
      @output << <<~ENDALLOCATION

        ALLOCATION
        -----------
        id:\t#{move.allocation.id}
        moves_count:\t#{move.allocation.moves_count}
        date:\t#{move.allocation.date}
        status:\t#{move.allocation.status}
        complete in full:\t#{move.allocation.complete_in_full}
        from location:\t#{move.allocation.from_location}
        to location:\t#{move.allocation.to_location}
        created at:\t#{move.allocation.created_at}
        updated at:\t#{move.allocation.updated_at}
      ENDALLOCATION

      if @include_person_details
        @output << "prisoner category:\t#{move.allocation.prisoner_category}\n"
        @output << "sentence length:\t#{move.allocation.sentence_length}\n"
        @output << "sentence length comment:\t#{move.allocation.sentence_length_comment}\n" if move.allocation.sentence_length_comment.present?
        @output << "estate:\t#{move.allocation.estate}\n"
        @output << "estate comment:\t#{move.allocation.estate_comment}\n" if move.allocation.estate_comment.present?
        @output << "other criteria:\t#{move.allocation.other_criteria}\n" if move.allocation.other_criteria.present?
        @output << "cancellation reason:\t#{move.allocation.cancellation_reason}\n" if move.allocation.cancellation_reason.present?
        @output << "cancellation reason comment:\t#{move.allocation.cancellation_reason_comment}\n" if move.allocation.cancellation_reason_comment.present?
        @output << "requested by:\t#{move.allocation.requested_by}\n"
      end
    end

    @output << <<~ENDMOVEEVENTS

      MOVE EVENTS
      -----------
    ENDMOVEEVENTS

    if move.generic_events.any?
      capture_events_errors(move) do |event_valid, object_valid, object_errors|
        # NB only show event params if include_person_details==true, as they could contain personal details
        @output << Terminal::Table.new { |t|
          t.headings = ['TIMESTAMP', 'EVENT', 'VALID', 'CREATED BY', 'NOTES', 'DETAILS']
          t.rows = move.generic_events.applied_order.map do |event|
            [
              event.occurred_at,
              event.event_type,
              event_valid[event.id],
              include_person_details ? event.created_by.to_s : '-',
              include_person_details ? event.notes.to_s.truncate(30) : '-',
              include_person_details ? event.details.to_s : '-',
            ]
          end
          t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
        }.to_s << "\n"

        @output << <<~ENDVALIDATION

          MOVE EVENT VALIDATION
          ---------------------
          valid:\t#{object_valid}
        ENDVALIDATION

        object_errors.each do |error|
          attribute = error.attribute
          message = error.message

          # we need to take care that we don't display any personal details in the error report
          @output << if @include_person_details
                       "  #{attribute.inspect}\t#{message}\t#{move.send(attribute)}\n"
                     else
                       "  #{attribute.inspect}\t#{message}\t-\n"
                     end
        end
      end
    else
      @output << "(no move events recorded)\n"
    end

    @output << <<~ENDLODGINGS

      LODGINGS
      --------
    ENDLODGINGS
    @output << if move.lodgings.not_cancelled.any?
                 Terminal::Table.new { |t|
                   t.headings = %w[START_DATE END_DATE LOCATION]
                   t.rows = move.lodgings.default_order.not_cancelled.map do |lodging|
                     [
                       lodging.start_date,
                       lodging.end_date,
                       lodging.location,
                     ]
                   end
                   t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
                 }.to_s << "\n"
               else
                 "(no lodgings planned)\n"
               end

    @output << <<~ENDLODGINGEVENTS

      LODGING EVENTS
      --------------
    ENDLODGINGEVENTS
    if move.lodgings.not_cancelled.any?
      move.lodgings.default_order.not_cancelled.each do |lodging|
        # NB use each to preserve sort order
        @output << "#{lodging.start_date} - #{lodging.end_date}: #{lodging.location}\n"
        if lodging.generic_events.any?
          @output << Terminal::Table.new { |t|
            t.headings = ['TIMESTAMP', 'EVENT', 'CREATED BY', 'NOTES', 'DETAILS']
            t.rows = lodging.generic_events.applied_order.map do |event|
              [
                event.occurred_at,
                event.event_type,
                include_person_details ? event.created_by.to_s : '-',
                include_person_details ? event.notes.to_s.truncate(30) : '-',
                include_person_details ? event.details.to_s : '-',
              ]
            end
            t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
          }.to_s << "\n"
        else
          @output << "  (no events recorded)\n"
        end
        @output << "\n"
      end
    else
      @output << "(no lodgings recorded)\n"
    end

    @output << <<~ENDJOURNEYS

      JOURNEYS
      --------
    ENDJOURNEYS

    @output << if move.journeys.any?
                 Terminal::Table.new { |t|
                   t.headings = ['TIMESTAMP', 'ID', 'STATE', 'BILLABLE', 'SUPPLIER', 'FROM --> TO']
                   t.rows = move.journeys.default_order.map do |journey|
                     [
                       journey.client_timestamp,
                       journey.id,
                       journey.state,
                       journey.billable,
                       journey.supplier.name,
                       "#{journey.from_location} --> #{journey.to_location}",
                     ]
                   end
                   t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
                 }.to_s << "\n"
               else
                 "(no journeys recorded)\n"
               end

    @output << <<~ENDJOURNEYEVENTS

      JOURNEY EVENTS
      --------------
    ENDJOURNEYEVENTS
    if move.journeys.any?
      move.journeys.default_order.each do |journey|
        # NB use each to preserve sort order
        @output << "#{journey.id}: #{journey.from_location} --> #{journey.to_location}\n"
        if journey.generic_events.any?

          capture_events_errors(journey) do |event_valid, object_valid, object_errors|
            @output << Terminal::Table.new { |t|
              t.headings = ['TIMESTAMP', 'EVENT', 'VALID', 'CREATED BY', 'NOTES', 'DETAILS']
              t.rows = journey.generic_events.applied_order.map do |event|
                [
                  event.occurred_at,
                  event.event_type,
                  event_valid[event.id],
                  include_person_details ? event.created_by.to_s : '-',
                  include_person_details ? event.notes.to_s.truncate(30) : '-',
                  include_person_details ? event.details.to_s : '-',
                ]
              end
              t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
            }.to_s << "\n"

            @output << "\n"
            @output << "  JOURNEY EVENT VALIDATION\n"
            @output << "  ------------------------\n"
            @output << "  valid:\t#{object_valid}\n"

            object_errors.each do |error|
              attribute = error.attribute
              message = error.message

              # we need to take care that we don't display any personal details in the error report
              @output << if @include_person_details
                           "  #{attribute.inspect}\t#{message}\t#{journey.send(attribute)}\n"
                         else
                           "  #{attribute.inspect}\t#{message}\t-\n"
                         end
            end
          end

        else
          @output << "  (no events recorded)\n"
        end
        @output << "\n"
      end
    else
      @output << "(no journeys recorded)\n"
    end

    if include_person_details
      if move.profile&.person_escort_record.present?
        per_inspector = Diagnostics::PerInspector.new(move.profile.person_escort_record)
      end

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

      @output << <<~ENDPER

        PERSON ESCORT RECORD
        --------------------
      ENDPER

      # NB: it is better to identify PERs via profile (not via move directly), as there are some older records which are
      # only associated with a profile but not with a move
      if per_inspector.present?
        @output << per_inspector.inspect

        @output << <<~ENDPEREVENTS

          PERSON ESCORT RECORD EVENTS
          ---------------------------
        ENDPEREVENTS

        @output << per_inspector.events

        if include_per_history
          @output << <<~ENDPERHISTORY

            PERSON ESCORT RECORD HISTORY
            ----------------------------
          ENDPERHISTORY

          @output << per_inspector.history
        end
      else
        @output << "(no person escort record recorded)\n"
      end

      @output << <<~ENDPER

        YOUTH RISK ASSESSMENT
        ---------------------
      ENDPER

      if move.profile&.youth_risk_assessment.present?
        move.profile.youth_risk_assessment.tap do |yra|
          @output << "id:\t#{yra.id}\n"
          @output << "framework version:\t#{yra.framework&.version}\n"
          @output << "framework_id:\t#{yra.framework_id}\n"
          @output << "profile_id:\t#{yra.profile_id}\n"
          @output << "move_id:\t#{yra.move_id}\n"
          @output << "prefill_source_id:\t#{yra.prefill_source_id}\n"
          @output << "section_progress:\n"
          yra.section_progress.each do |section|
            @output << "* #{section['key']}:\t#{section['status']}\n"
          end
          @output << "status:\t#{yra.status}\n"
          @output << "created at:\t#{yra.created_at}\n"
          @output << "updated at:\t#{yra.updated_at}\n"
          @output << "completed at:\t#{yra.completed_at}\n"
          @output << "confirmed at:\t#{yra.confirmed_at}\n"
        end
      else
        @output << "(no youth risk assessment recorded)\n"
      end
    end

    topics = [move]
    topics << move.profile.person_escort_record if move.profile&.person_escort_record.present?
    topics << move.profile.youth_risk_assessment if move.profile&.youth_risk_assessment.present?
    notifications = Notification.where(topic: topics)

    @output << <<~WEBHOOKS

      WEBHOOK NOTIFICATIONS
      ---------------------
    WEBHOOKS

    @output << if notifications.webhooks.any?
                 Terminal::Table.new { |t|
                   t.headings = ['DELIVERED AT', 'TYPE', 'ATTEMPTS', 'ENDPOINT']
                   t.rows = notifications.webhooks.order(:created_at).map do |notification|
                     [
                       notification.delivered_at,
                       notification.event_type,
                       notification.delivery_attempts,
                       notification.subscription.callback_url,
                     ]
                   end
                   t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
                 }.to_s << "\n"
               else
                 "(no notifications recorded)\n"
               end

    @output << <<~EMAILS

      EMAIL NOTIFICATIONS
      -------------------
    EMAILS

    @output << if notifications.emails.any?
                 Terminal::Table.new { |t|
                   t.headings = ['DELIVERED AT', 'TYPE', 'ATTEMPTS', 'EMAIL']
                   t.rows = notifications.webhooks.order(:created_at).map do |notification|
                     [
                       notification.delivered_at,
                       notification.event_type,
                       notification.delivery_attempts,
                       notification.subscription.email_address,
                     ]
                   end
                   t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
                 }.to_s << "\n"
               else
                 "(no notifications recorded)\n"
               end

    @output
  end

  def capture_events_errors(object)
    event_valid = {}

    GenericEvents::Runner.new(object, dry_run: true).call do |event|
      event_valid[event.id] = object.validate
    end

    yield event_valid, object.validate, object.errors

    # it is important to reload the original object, to prevent the implied or failed changes from being propagated
    object.reload
  end
end

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
          @output << "#{'EVENT'.ljust(30)}\t#{'OCCURRED AT'.ljust(27)}\t#{'VALID'.ljust(6)}\t#{'CREATED BY'.ljust(15)}\t#{'NOTES'.ljust(30)}\tDETAILS\n"
          move.generic_events.applied_order.each do |event| # NB use each to preserve sort order
            # NB only show event params if include_person_details==true, as they could contain personal details
            @output << "#{event.event_type.ljust(30)}\t#{event.occurred_at.to_s.ljust(27)}\t#{event_valid[event.id].to_s.ljust(6)}\t#{include_person_details ? event.created_by.to_s.truncate(15).ljust(15) : '-'.ljust(15)}\t#{include_person_details ? event.notes.to_s.truncate(30).ljust(30) : '-'.ljust(30)}\t#{include_person_details ? event.details : '-'}\n"
          end

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

      @output << <<~ENDJOURNEYS

        JOURNEYS
        --------
      ENDJOURNEYS

      if move.journeys.any?
        @output << "#{'ID'.ljust(37)}\t#{'TIMESTAMP'.ljust(27)}\t#{'STATE'.ljust(12)}\t#{'BILLABLE'.ljust(9)}\t#{'SUPPLIER'.ljust(9)}\tFROM --> TO\n"
        move.journeys.default_order.each do |journey| # NB use each to preserve sort order
          @output << "#{journey.id.to_s.ljust(37)}\t#{journey.client_timestamp.to_s.ljust(27)}\t#{journey.state.to_s.ljust(12)}\t#{journey.billable.to_s.ljust(9)}\t#{journey.supplier.name.ljust(9)}\t#{journey.from_location} --> #{journey.to_location}\n"
        end
      else
        @output << "(no journeys recorded)\n"
      end

      @output << <<~ENDJOURNEYEVENTS

        JOURNEY EVENTS
        --------------
      ENDJOURNEYEVENTS
      if move.journeys.any?
        move.journeys.default_order.each do |journey| # NB use each to preserve sort order
          @output << "#{journey.id}: #{journey.from_location} --> #{journey.to_location}\n"
          if journey.generic_events.any?

            capture_events_errors(journey) do |event_valid, object_valid, object_errors|
              @output << "  #{'EVENT'.ljust(30)}\t#{'OCCURRED AT'.ljust(27)}\t#{'VALID'.ljust(6)}\t#{'CREATED BY'.ljust(15)}\t#{'NOTES'.ljust(30)}\tDETAILS\n"
              journey.generic_events.applied_order.each do |event| # NB use each to preserve sort order
                # NB only show event params if include_person_details==true, as they could contain personal details
                @output << "  #{event.event_type.ljust(30)}\t#{event.occurred_at.to_s.ljust(27)}\t#{event_valid[event.id].to_s.ljust(6)}\t#{include_person_details ? event.created_by.to_s.truncate(15).ljust(15) : '-'.ljust(15)}\t#{include_person_details ? event.notes.to_s.truncate(30).ljust(30) : '-'.ljust(30)}\t#{include_person_details ? event.details : '-'}\n"
              end

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
        if move.profile&.person_escort_record.present?
          move.profile.person_escort_record.tap do |per|
            @output << "id:\t#{per.id}\n"
            @output << "framework version:\t#{per.framework&.version}\n"
            @output << "framework_id:\t#{per.framework_id}\n"
            @output << "profile_id:\t#{per.profile_id}\n"
            @output << "move_id:\t#{per.move_id}\n"
            @output << "prefill_source_id:\t#{per.prefill_source_id}\n"
            @output << "section_progress:\n"
            per.section_progress.each do |section|
              @output << "* #{section['key']}:\t#{section['status']}\n"
            end
            @output << "status:\t#{per.status}\n"
            @output << "created at:\t#{per.created_at}\n"
            @output << "updated at:\t#{per.updated_at}\n"
            @output << "completed at:\t#{per.completed_at}\n"
            @output << "amended at:\t#{per.amended_at}\n"
            @output << "confirmed at:\t#{per.confirmed_at}\n"
            @output << "handover at:\t#{per.handover_occurred_at}\n"

            @output << <<~ENDPERHISTORY

              PER CHANGE HISTORY
              ------------------

            ENDPERHISTORY

            per.framework_responses.group_by(&:section).each do |section, responses|
              @output << "START OF SECTION:\t#{section}\n"
              responses.each do |response|
                @output << "QUESTION:\t#{response.framework_question.key}\n"
                response.versions.each do |version|
                  diff(version.reify&.value, version.next&.reify&.value || response.value, version.whodunnit)
                end
                @output << "--------------------------------------------------------------------------------\n"
              end
              @output << "END OF SECTION:\t#{section}\n"
            end
          end
        else
          @output << "(no person escort record recorded)\n"
        end

        @output << <<~ENDPEREVENTS

          PERSON ESCORT RECORD EVENTS
          ---------------------------
        ENDPEREVENTS

        if move.profile&.person_escort_record&.generic_events.present?
          @output << "#{'EVENT'.ljust(30)}\t#{'OCCURRED AT'.ljust(27)}\t#{'NOTES'.ljust(30)}\tDETAILS\n"
          move.profile.person_escort_record.generic_events.applied_order.each do |event| # NB use each to preserve sort order
            # NB only show event params if include_person_details==true, as they could contain personal details
            @output << "#{event.event_type.ljust(30)}\t#{event.occurred_at.to_s.ljust(27)}\t#{include_person_details ? event.notes.to_s.truncate(30).ljust(30) : '-'.ljust(30)}\t#{include_person_details ? event.details : '-'}\n"
          end
        else
          @output << "(no person escort record events recorded)\n"
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
      if notifications.webhooks.any?
        @output << "#{'TYPE'.ljust(18)}\t#{'DELIVERED AT'.ljust(27)}\t#{'ATTEMPTS'.ljust(9)}\tENDPOINT\n"
        notifications.webhooks.order(:created_at).each do |notification|
          @output << "#{notification.event_type.ljust(18)}\t#{notification.delivered_at.to_s.ljust(27)}\t#{notification.delivery_attempts.to_s.ljust(9)}\t#{notification.subscription.callback_url}\n"
        end
      else
        @output << "(no notifications recorded)\n"
      end

      @output << <<~EMAILS

        EMAIL NOTIFICATIONS
        -------------------
      EMAILS
      if notifications.emails.any?
        @output << "#{'TYPE'.ljust(18)}\t#{'DELIVERED AT'.ljust(27)}\t#{'ATTEMPTS'.ljust(9)}\tEMAIL\n"
        notifications.emails.order(:created_at).each do |notification|
          @output << "#{notification.event_type.ljust(18)}\t#{notification.delivered_at.to_s.ljust(27)}\t#{notification.delivery_attempts.to_s.ljust(9)}\t#{notification.subscription.email_address}\n"
        end
      else
        @output << "(no notifications recorded)\n"
      end

      @output
    end

    def diff(old_value, new_value, whodunnit)
      if old_value != new_value
        @output << "--------------------------\n"
        @output << "old value:\t#{old_value}\n"
        @output << "new value:\t#{new_value}\n"
        @output << "whodunnit:\t#{whodunnit}\n"
        @output << "--------------------------\n"
      end
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
end

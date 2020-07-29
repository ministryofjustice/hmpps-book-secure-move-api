module EventLog
  class MoveRunner
    attr_reader :move

    def initialize(move)
      @move = move
    end

    # Process events in order of client_timestamp
    def call
      # iterate over all events in the log and apply changes to the move
      events.each do |event| # NB: do not use events.find_each as it will break the ordering
        case event.event_name
        when Event::ACCEPT
          move.status = Move::MOVE_STATUS_BOOKED
        when Event::APPROVE
          move.status = Move::MOVE_STATUS_REQUESTED
          move.date = event.date
          Allocations::CreateInNomis.call(move) if event.create_in_nomis?
        when Event::CANCEL
          move.status = Move::MOVE_STATUS_CANCELLED
          move.cancellation_reason = event.cancellation_reason
          move.cancellation_reason_comment = event.cancellation_reason_comment
        when Event::COMPLETE
          move.status = Move::MOVE_STATUS_COMPLETED
        when Event::LOCKOUT
          # no action to perform when a move is locked out, this event is purely for auditing
        when Event::REDIRECT
          move.to_location = event.to_location
        when Event::REJECT
          move.status = Move::MOVE_STATUS_CANCELLED
          move.rejection_reason = event.rejection_reason
          move.cancellation_reason = Move::CANCELLATION_REASON_REJECTED
          move.cancellation_reason_comment = event.cancellation_reason_comment
          move.rebook if event.rebook?
        when Event::START
          move.status = Move::MOVE_STATUS_IN_TRANSIT
          # TODO: handle other move events here
        end
      end

      # save the move if it has changed, and notify webhooks and emails
      if move.changed?
        action_name = move.status_changed? ? 'update_status' : 'update'
        move.save! # save before notifying
        Notifier.prepare_notifications(topic: move, action_name: action_name)
        true
      else
        false
      end
    end

  private

    def events
      move.move_events.default_order
    end
  end
end

module EventLog
  class MoveRunner
    attr_reader :move

    def initialize(move)
      @move = move
    end

    # Process events in order of client_timestamp
    def call
      events.map(&:trigger)

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
      move.generic_events.applied_order
    end
  end
end

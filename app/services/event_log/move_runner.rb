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
        when 'redirect'
          move.to_location = event.to_location
        when 'complete'
          move.status = Move::MOVE_STATUS_COMPLETED
          # TODO: handle other move events here
        end
      end

      # save the move if it has changed, and notify webhooks and emails
      if move.changed?
        action_name = move.status_changed? ? 'update_status' : 'update'
        Notifier.prepare_notifications(topic: move, action_name: action_name)
        move.save!
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

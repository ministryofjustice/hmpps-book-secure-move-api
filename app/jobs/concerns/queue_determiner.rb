module QueueDeterminer
  extend ActiveSupport::Concern

  def move_queue_priority(move)
    case move&.date
    when Time.zone.today
      # moves for today are high priority
      :notifications_high
    when Time.zone.tomorrow
      # moves for tomorrow are medium priority
      :notifications_medium
    else
      # any other past/future moves are low priority
      :notifications_low
    end
  end

  included do
    queue_as do
      # defaults to medium priority if queue not specified
      arguments.first[:queue_as] || :notifications_medium
    end
  end
end

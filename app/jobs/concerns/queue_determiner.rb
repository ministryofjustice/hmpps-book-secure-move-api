module QueueDeterminer
  extend ActiveSupport::Concern

  included do
    queue_as { queue_as }

    def queue_as
      @queue_as ||= begin

                      if self.arguments.first.is_a?(Hash)
                        queue_as = self.arguments.first.delete(:queue_as) # NB: delete() is necessary to prevent it from being passed on as a parameter to perform()
                        topic_id = self.arguments.first[:topic_id]
                      else
                        queue_as = nil
                        topic_id = nil
                      end

                      if queue_as.present?
                        # if the job has a queue_as parameter use it
                        puts "USING SUPPLIED QUEUENAME: #{queue_as}"
                        queue_as

                        # else if the job concerns a move, prioritise by move date
                      elsif topic_id.present? && (move_date = Move.find_by(id: topic_id)&.date)
                        case move_date
                        when Time.zone.today
                          puts "TODAY"
                          # moves for today are high priority
                          :notifications_high
                        when Time.zone.tomorrow
                          puts "TOMORROW"
                          # moves for tomorrow are medium priority
                          :notifications_medium
                        else
                          # any other past/future moves are low priority
                          puts "OTHER"
                          :notifications_low
                        end
                      else
                        # otherwise, default to medium priority
                        puts "USING DEFAULT MEDIUM QUEUE"
                        :notifications_medium
                      end
                    end


    end
  end
end

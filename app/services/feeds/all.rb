module Feeds
  class All < Feeds::Jpc
  private

    def event_feed
      super.tap do |feed|
        profiles.find_each do |profile|
          profile.person_escort_record&.generic_events&.find_each do |event|
            feed << event.for_feed.to_json
          end
          profile.youth_risk_assessment&.generic_events&.find_each do |event|
            feed << event.for_feed.to_json
          end
        end
        moves.find_each do |move|
          move.person_escort_record&.generic_events&.find_each do |event|
            feed << event.for_feed.to_json
          end
          move.youth_risk_assessment&.generic_events&.find_each do |event|
            feed << event.for_feed.to_json
          end
        end
      end
    end
  end
end

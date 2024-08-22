module Feeds
  class Jpc
    def initialize(date_from = nil, date_to = nil)
      @date_from = date_from || Time.zone.yesterday.beginning_of_day
      @date_to = date_to || Time.zone.yesterday.end_of_day
    end

    def call
      {
        move: move_feed,
        profile: profile_feed,
        person: person_feed,
        journey: journey_feed,
        event: event_feed,
      }.transform_values { |feed| feed.join("\n") }
    end

  private

    def moves
      ::Move.includes(:supplier, :from_location, :to_location)
        .where(date: @date_from..@date_to)
        .or(::Move.where(date: ...@date_from)
        .updated_at_range(@date_from, @date_to))
    end

    def journeys
      ::Journey.includes(:supplier, :from_location)
        .joins(:move)
        .where('moves.date' => @date_from..@date_to)
        .or(::Journey.where('moves.date' => ...@date_from, 'moves.updated_at' => @date_from..@date_to))
    end

    def profiles
      ::Profile.updated_at_range(@date_from, @date_to)
    end

    def move_feed
      [].tap do |feed|
        moves.find_each do |move|
          feed << move.for_feed.to_json
        end
      end
    end

    def journey_feed
      [].tap do |feed|
        journeys.find_each do |journey|
          feed << journey.for_feed.to_json
        end
      end
    end

    def event_feed
      [].tap do |feed|
        moves.find_each do |move|
          move.generic_events.find_each do |event|
            feed << event.for_feed.to_json
          end
        end
        journeys.find_each do |journey|
          journey.generic_events.find_each do |event|
            feed << event.for_feed.to_json
          end
        end
      end
    end

    def profile_feed
      [].tap do |feed|
        profiles.find_each do |profile|
          feed << profile.for_feed.to_json
        end
      end
    end

    def person_feed
      [].tap do |feed|
        ::Person.updated_at_range(@date_from, @date_to).find_each do |person|
          feed << person.for_feed.to_json
        end
      end
    end
  end
end

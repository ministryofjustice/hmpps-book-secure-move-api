# frozen_string_literal: true

namespace :backfill do
  desc 'Populate journeys with dates from the associated move.'
  task journey_dates: :environment do
    Journey.where(date: nil).includes(:move).find_each do |journey|
      journey.update!(date: journey.move.date)
    end
  end
end

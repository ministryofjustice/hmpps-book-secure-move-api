# frozen_string_literal: true

namespace :backfill do
  desc 'Populate journeys with dates from the associated move.'
  task :journey_dates, [:limit] => :environment do |_, args|
    limit = args.fetch(:limit).to_i
    Journey.where(date: nil).includes(:move).limit(limit).find_each do |journey|
      journey.update!(date: journey.move.date)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['backfill:journey_dates'] do
  before do
    3.times do
      move = create(:move, date: Faker::Date.in_date_period)
      create(:journey, move: move, date: nil)
    end
  end

  let!(:journey_to_ignore) { create(:journey, date: '2020-01-01') }

  it 'sets the journey dates to the move date' do
    described_class.invoke('10')

    expect(Journey.where(date: nil)).not_to exist

    Journey.where.not(id: journey_to_ignore.id).find_each do |journey|
      expect(journey.date).to eq(journey.move.date)
    end

    expect(journey_to_ignore.date).to eq(Date.new(2020, 1, 1))
  end
end

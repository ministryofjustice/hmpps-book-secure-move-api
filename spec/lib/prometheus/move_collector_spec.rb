# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus/move_collector'

RSpec.describe MoveCollector do
  subject(:metric) { described_class.new.metrics.first.to_h }

  let(:supplier1) { create(:supplier) }
  let(:supplier2) { create(:supplier) }

  before do
    create(:move, :cancelled, supplier: supplier1, date: 1.year.ago.to_date)
    create(:move, :cancelled, supplier: supplier2, date: 4.weeks.ago.to_date)
    create(:move, :completed, supplier: supplier1, date: 6.days.ago.to_date)
    create(:move, :completed, supplier: supplier2, date: 1.day.ago.to_date)
    create(:move, :booked, supplier: supplier2, date: Time.zone.today)
    create(:move, :in_transit, supplier: supplier2, date: 1.day.from_now.to_date)
    create(:move, :requested, supplier: supplier1, date: 6.days.from_now.to_date)
    create(:move, :requested, supplier: supplier2, date: 4.weeks.from_now.to_date)
    create(:move, :proposed, supplier: supplier2, date: 1.year.from_now.to_date)
  end

  it 'move count for all statuses, all suppliers, all dates' do
    expect(metric[{ status: '*', supplier: '*', date_from_offset: '*', date_to_offset: '*' }]).to be(9)
  end

  it 'move count for supplier1' do
    expect(metric[{ status: '*', supplier: supplier1.key, date_from_offset: '*', date_to_offset: '*' }]).to be(3)
  end

  it 'move count for supplier2' do
    expect(metric[{ status: '*', supplier: supplier2.key, date_from_offset: '*', date_to_offset: '*' }]).to be(6)
  end

  it 'move count for requested moves' do
    expect(metric[{ status: 'requested', supplier: '*', date_from_offset: '*', date_to_offset: '*' }]).to be(2)
  end

  it 'move count for cancelled moves for supplier 2' do
    expect(metric[{ status: 'cancelled', supplier: supplier2.key, date_from_offset: '*', date_to_offset: '*' }]).to be(1)
  end

  it 'move count for today' do
    expect(metric[{ status: '*', supplier: '*', date_from_offset: 0, date_to_offset: 0 }]).to be(1)
  end

  it 'move count for past 6 days including today' do
    expect(metric[{ status: '*', supplier: '*', date_from_offset: -6, date_to_offset: 0 }]).to be(3)
  end

  it 'move count for next 29 days including today' do
    expect(metric[{ status: '*', supplier: '*', date_from_offset: 0, date_to_offset: 29 }]).to be(4)
  end

  it 'booked move count for supplier2 for today' do
    expect(metric[{ status: 'booked', supplier: supplier2.key, date_from_offset: 0, date_to_offset: 0 }]).to be(1)
  end

  it 'in_transit move count for supplier2 for tomorrow' do
    expect(metric[{ status: 'in_transit', supplier: supplier2.key, date_from_offset: 1, date_to_offset: 1 }]).to be(1)
  end
end

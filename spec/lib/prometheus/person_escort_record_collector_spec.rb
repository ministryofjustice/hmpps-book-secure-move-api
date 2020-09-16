# frozen_string_literal: true

require 'prometheus_exporter/server'
require 'prometheus/person_escort_record_collector'

RSpec.describe PersonEscortRecordCollector do
  subject(:metric) { described_class.new.metrics.first.to_h }

  before do
    create(:person_escort_record, status: :unstarted)
    create(:person_escort_record, :in_progress)
    create(:person_escort_record, :completed)
    create(:person_escort_record, :confirmed, confirmed_at: 1.year.ago)
    create(:person_escort_record, :confirmed, confirmed_at: 4.weeks.ago)
    create(:person_escort_record, :confirmed, confirmed_at: 6.days.ago)
    create(:person_escort_record, :confirmed, confirmed_at: 1.day.ago)
    create(:person_escort_record, :confirmed, confirmed_at: Time.zone.now)
  end

  it 'PER count for all statuses' do
    expect(metric[{ status: nil, confirmed_at_from_offset: nil, confirmed_at_to_offset: nil }]).to be(8)
  end

  it 'unstarted PER count' do
    expect(metric[{ status: 'unstarted', confirmed_at_from_offset: nil, confirmed_at_to_offset: nil }]).to be(1)
  end

  it 'in_progress PER count' do
    expect(metric[{ status: 'in_progress', confirmed_at_from_offset: nil, confirmed_at_to_offset: nil }]).to be(1)
  end

  it 'completed PER count' do
    expect(metric[{ status: 'completed', confirmed_at_from_offset: nil, confirmed_at_to_offset: nil }]).to be(1)
  end

  it 'confirmed PER count' do
    expect(metric[{ status: 'confirmed', confirmed_at_from_offset: nil, confirmed_at_to_offset: nil }]).to be(5)
  end

  it 'confirmed PER count for past 29 days including today' do
    expect(metric[{ status: 'confirmed', confirmed_at_from_offset: -29, confirmed_at_to_offset: 0 }]).to be(4)
  end

  it 'confirmed PER count for past 6 days including today' do
    expect(metric[{ status: 'confirmed', confirmed_at_from_offset: -6, confirmed_at_to_offset: 0 }]).to be(3)
  end

  it 'confirmed PER count for yesterday excluding today' do
    expect(metric[{ status: 'confirmed', confirmed_at_from_offset: -1, confirmed_at_to_offset: -1 }]).to be(1)
  end

  it 'confirmed PER count for today' do
    expect(metric[{ status: 'confirmed', confirmed_at_from_offset: 0, confirmed_at_to_offset: 0 }]).to be(1)
  end
end

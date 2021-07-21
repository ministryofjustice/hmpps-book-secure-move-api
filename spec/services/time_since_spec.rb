require 'rails_helper'

RSpec.describe TimeSince do
  around do |example|
    Timecop.freeze('2021-01-01 00:00:00')
    example.run
    Timecop.return
  end

  context 'without passing a date' do
    it 'returns the correct value' do
      time_since = described_class.new
      Timecop.freeze('2021-01-02 00:00:00')
      expect(time_since.get).to eq(1.day.seconds)
    end
  end

  context 'when passing a date' do
    it 'returns the correct value' do
      time_since = described_class.new(Time.zone.local(2020, 12, 30))
      expect(time_since.get).to eq(2.days.seconds)
      expect(time_since.get(Time.zone.local(2020, 12, 31))).to eq(1.day.seconds)
    end
  end
end

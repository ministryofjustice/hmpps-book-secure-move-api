require 'rails_helper'

RSpec.describe CourtHearing, type: :model do
  subject(:court_hearing) do
    build(:court_hearing, start_time: start_time)
  end

  context 'when the start_time is missing' do
    let(:start_time) { nil }

    it 'is not valid' do
      expect(court_hearing).not_to be_valid
    end
  end

  context 'when the start_time is not missing' do
    let(:start_time) { Time.zone.now }

    it 'is not valid' do
      expect(court_hearing).to be_valid
    end
  end
end

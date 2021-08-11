require 'rails_helper'

RSpec.describe CourtHearing, type: :model do
  describe 'default factory' do
    subject { build(:court_hearing) }

    it { is_expected.to be_valid }
  end

  describe 'start_time field' do
    subject { build(:court_hearing, start_time: start_time) }

    context 'when nil' do
      let(:start_time) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when set' do
      let(:start_time) { Time.zone.now }

      it { is_expected.to be_valid }
    end
  end

  describe 'comments field' do
    subject { build(:court_hearing, comments: comments) }

    context 'when nil' do
      let(:comments) { nil }

      it { is_expected.to be_valid }
    end

    context 'when set to a short string' do
      let(:comments) { 'This is a comment.' }

      it { is_expected.to be_valid }
    end

    context 'when set to a long string' do
      let(:comments) { SecureRandom.alphanumeric(1000) }

      it { is_expected.not_to be_valid }
    end
  end
end

require 'rails_helper'

RSpec.describe Feeds::Profile do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_profile) { create(:profile, updated_at: updated_at_from) }
    let!(:on_end_profile) { create(:profile, updated_at: updated_at_to) }

    let(:expected_json) do
      [on_start_profile, on_end_profile].sort_by(&:id).map { |profile| JSON.parse(profile.for_feed.to_json) }
    end

    it 'returns correctly formatted feed' do
      actual = feed.call.split("\n").map { |profile| JSON.parse(profile) }

      expect(actual).to include_json(expected_json)
    end
  end
end

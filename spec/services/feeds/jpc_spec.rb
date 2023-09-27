require 'rails_helper'

RSpec.describe Feeds::Jpc do
  subject(:feed) { described_class.new(date_from, date_to) }

  let(:date_from) { Time.zone.yesterday.beginning_of_day }
  let(:date_to) { Time.zone.yesterday.end_of_day }

  describe '#call' do
    let!(:scheduled_on_date_move) { create(:move, date: date_from, profile: other_profile) }
    let!(:updated_on_date_move) { create(:move, date: date_from.yesterday, profile: other_profile) }
    let!(:other_date_move) { create(:move, date: date_from.tomorrow, profile: other_profile) }

    let!(:journey1) { create(:journey, move: scheduled_on_date_move) }
    let!(:journey2) { create(:journey, move: updated_on_date_move) }
    let!(:journey3) { create(:journey, move: other_date_move) }

    let!(:event1) { create(:event_move_cancel, eventable: scheduled_on_date_move) }
    let!(:event2) { create(:event_move_cancel, eventable: updated_on_date_move) }
    let!(:event3) { create(:event_move_cancel, eventable: other_date_move) }
    let!(:event4) { create(:event_journey_cancel, eventable: journey1) }
    let!(:event5) { create(:event_journey_cancel, eventable: journey2) }
    let!(:event6) { create(:event_journey_cancel, eventable: journey3) }

    let!(:on_start_profile) { create(:profile) }
    let!(:on_end_profile) { create(:profile) }
    let!(:other_profile) { create(:profile) }

    let!(:on_start_person) { create(:person) }
    let!(:on_end_person) { create(:person) }
    let!(:other_person) { create(:person) }

    let(:expected_moves) do
      [scheduled_on_date_move, updated_on_date_move].sort_by(&:id).map { |move| JSON.parse(move.for_feed.to_json) }
    end

    let(:expected_journeys) do
      [journey1, journey2].sort_by(&:id).map { |journey| JSON.parse(journey.for_feed.to_json) }
    end

    let(:expected_events) do
      [event1, event2, event4, event5].map { |event| JSON.parse(event.for_feed.to_json) }
    end

    let(:unexpected_events) do
      [event3, event6].map { |event| JSON.parse(event.for_feed.to_json) }
    end

    let(:expected_profiles) do
      [on_start_profile, on_end_profile].sort_by(&:id).map { |profile| JSON.parse(profile.for_feed.to_json) }
    end

    let(:expected_people) do
      [on_start_person, on_end_person].sort_by(&:id).map { |person| JSON.parse(person.for_feed.to_json) }
    end

    # rubocop:disable Rails/SkipsModelValidations
    before do
      scheduled_on_date_move.update_attribute('updated_at', date_from.yesterday)
      updated_on_date_move.update_attribute('updated_at', date_from)
      other_date_move.update_attribute('updated_at', date_from.days_ago(2))
      on_start_profile.update_attribute('updated_at', date_from)
      on_end_profile.update_attribute('updated_at', date_to)
      other_profile.update_attribute('updated_at', date_from.days_ago(2))
      on_start_person.update_attribute('updated_at', date_from)
      on_end_person.update_attribute('updated_at', date_to)
      other_person.update_attribute('updated_at', date_from.days_ago(2))
    end
    # rubocop:enable Rails/SkipsModelValidations

    it 'returns correctly formatted move feed' do
      actual = feed.call[:move].split("\n").map { |move| JSON.parse(move) }

      expect(actual).to include_json(expected_moves)
    end

    it 'returns correctly formatted journey feed' do
      actual = feed.call[:journey].split("\n").map { |journey| JSON.parse(journey) }

      expect(actual).to include_json(expected_journeys)
    end

    it 'returns correctly formatted event feed' do
      expected_events.each { |event| expect(feed.call[:event]).to include(event.to_json) }
      unexpected_events.each { |event| expect(feed.call[:event]).not_to include(event.to_json) }
    end

    it 'returns correctly formatted profile feed' do
      actual = feed.call[:profile].split("\n").map { |profile| JSON.parse(profile) }

      expect(actual).to include_json(expected_profiles)
    end

    it 'returns correctly formatted person feed' do
      actual = feed.call[:person].split("\n").map { |person| JSON.parse(person) }

      expect(actual).to include_json(expected_people)
    end
  end
end

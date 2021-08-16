require 'rails_helper'

RSpec.describe Feeds::Person do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_person) { create(:person, updated_at: updated_at_from) }
    let!(:on_end_person) { create(:person, updated_at: updated_at_to) }

    let(:expected_json) do
      [on_start_person, on_end_person].sort_by(&:id).map { |person| JSON.parse(person.for_feed.to_json) }
    end

    it 'returns correctly formatted feed' do
      on_start_person.update!(updated_at: updated_at_from)
      on_end_person.update!(updated_at: updated_at_to)
      actual = feed.call.split("\n").map { |person| JSON.parse(person) }
      expect(actual).to include_json(expected_json)
    end
  end
end

require 'rails_helper'

RSpec.describe Feeds::Event do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_event) { create(:event_move_cancel, updated_at: updated_at_from) }
    let!(:on_end_event) { create(:event_journey_cancel, updated_at: updated_at_to) }

    let(:expected_json) do
      [on_start_event, on_end_event].sort_by(&:id).map { |event| JSON.parse(event.for_feed.to_json) }
    end

    it 'returns correctly formatted feed' do
      on_start_event.update!(updated_at: updated_at_from)
      on_end_event.update!(updated_at: updated_at_to)
      actual = feed.call.split("\n").map { |event| JSON.parse(event) }
      expect(actual).to include_json(expected_json)
    end
  end
end

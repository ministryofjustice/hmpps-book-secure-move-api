RSpec.describe Feeds::Move do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_move) { create(:move, updated_at: updated_at_from) }
    let!(:on_end_move) { create(:move, updated_at: updated_at_to) }

    let(:expected_jsonl) do
      on_end_move.for_feed.to_json + "\n" + on_start_move.for_feed.to_json
    end

    it 'returns correctly formatted feed' do
      expect(feed.call).to eq(expected_jsonl)
    end
  end
end

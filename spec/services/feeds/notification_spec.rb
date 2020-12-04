RSpec.describe Feeds::Notification do
  subject(:feed) { described_class.new(created_at_from, created_at_to) }

  let(:created_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:created_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_notification) { create(:notification, created_at: created_at_from) }
    let!(:on_end_notification) { create(:notification, created_at: created_at_to) }

    let(:expected_json) do
      [on_start_notification, on_end_notification].sort_by(&:id).map { |notification| JSON.parse(notification.for_feed.to_json) }
    end

    it 'returns correctly formatted feed' do
      on_start_notification.update(created_at: created_at_from)
      on_end_notification.update(created_at: created_at_to)
      actual = feed.call.split("\n").map { |notification| JSON.parse(notification) }
      expect(actual).to include_json(expected_json)
    end
  end
end

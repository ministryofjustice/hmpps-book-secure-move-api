# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to belong_to(:topic) }
  it { is_expected.to validate_presence_of(:event_type) }
  it { is_expected.to validate_presence_of(:topic) }

  describe 'kept?' do
    subject(:notification) { build(:notification, :webhook, subscription: subscription, discarded_at: discarded_at) }

    context 'when parent subscription is discarded' do
      let(:subscription) { create(:subscription, discarded_at: Time.now) }

      context 'when notification is discarded' do
        let(:discarded_at) { Time.now }

        it { expect(notification.kept?).to be false }
      end

      context 'when notification is not discarded' do
        let(:discarded_at) { nil }

        it { expect(notification.kept?).to be false }
      end
    end

    context 'when parent subscription is not discarded' do
      let(:subscription) { build(:subscription, discarded_at: nil) }

      context 'when notification is discarded' do
        let(:discarded_at) { Time.now }

        it { expect(notification.kept?).to be false }
      end

      context 'when notification is not discarded' do
        let(:discarded_at) { nil }

        it { expect(notification.kept?).to be true }
      end
    end
  end

  describe 'relationships' do
    it 'updates the parent record when updated' do
      topic = create(:move)
      notification = create(:notification, topic: topic)

      expect { notification.update(delivery_attempted_at: notification.delivery_attempted_at + 1.day) }.to change { topic.reload.updated_at }
    end

    it 'updates the parent record when created' do
      topic = create(:move)

      expect { create(:notification, topic: topic) }.to change { topic.reload.updated_at }
    end
  end

  describe '#for_feed' do
    subject(:notification) { create(:notification, :email) }

    let(:expected_json) do
      {
        'id' => notification.id,
        'event_type' => 'move_created',
        'topic_id' => notification.topic_id,
        'topic_type' => notification.topic_type,
        'delivery_attempts' => 0,
        'delivery_attempted_at' => be_a(Time),
        'delivered_at' => be_a(Time),
        'discarded_at' => nil,
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'response_id' => nil,
        'notification_type_id' => 'email',
      }
    end

    it 'generates a feed document' do
      expect(notification.for_feed).to include_json(expected_json)
    end
  end

  describe '.updated_at_range' do
    let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
    let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

    it 'returns the expected notifications' do
      create(:notification, updated_at: updated_at_from - 1.second)
      create(:notification, updated_at: updated_at_to + 1.second)
      on_start_notification = create(:notification, updated_at: updated_at_from)
      on_end_notification = create(:notification, updated_at: updated_at_to)

      actual_notifications = described_class.updated_at_range(
        updated_at_from,
        updated_at_to,
      )
      expect(actual_notifications).to eq([on_start_notification, on_end_notification])
    end
  end
end

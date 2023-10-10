# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to belong_to(:topic) }
  it { is_expected.to validate_presence_of(:event_type) }
  it { is_expected.to validate_presence_of(:topic) }

  describe 'kept?' do
    subject(:notification) { build(:notification, :webhook, subscription:, discarded_at:) }

    context 'when parent subscription is discarded' do
      let(:subscription) { create(:subscription, discarded_at: Time.zone.now) }

      context 'when notification is discarded' do
        let(:discarded_at) { Time.zone.now }

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
        let(:discarded_at) { Time.zone.now }

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
      notification = create(:notification, topic:)

      expect { notification.update(delivery_attempted_at: notification.delivery_attempted_at + 1.day) }.to(change { topic.reload.updated_at })
    end

    it 'updates the parent record when created' do
      topic = create(:move)

      expect { create(:notification, topic:) }.to(change { topic.reload.updated_at })
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

  describe 'mailer' do
    it 'returns correct mailer class for a PersonEscortRecord' do
      topic = create(:person_escort_record)
      notification = build(:notification, topic:)

      expect(notification.mailer).to eq(PersonEscortRecordMailer)
    end

    it 'returns correct mailer class for a Move' do
      topic = create(:move)
      notification = build(:notification, topic:)

      expect(notification.mailer).to eq(MoveMailer)
    end
  end
end

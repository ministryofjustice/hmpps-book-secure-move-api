# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to belong_to(:topic) }
  it { is_expected.to validate_presence_of(:event_type) }
  it { is_expected.to validate_presence_of(:topic) }

  describe 'kept?' do
    subject(:notification) { create(:notification, :webhook, subscription: subscription, discarded_at: discarded_at) }

    context 'when parent subscription is discarded' do
      let(:subscription) { build(:subscription, discarded_at: Time.now) }

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
end

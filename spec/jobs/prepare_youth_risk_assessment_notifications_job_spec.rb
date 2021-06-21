# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrepareYouthRiskAssessmentNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(topic_id: assessment.id, action_name: 'confirm_youth_risk_assessment', queue_as: :some_queue_name, send_webhooks: true, send_emails: false, only_supplier_id: nil)
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, :secure_childrens_home, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: supplier }
  let(:assessment) { create :youth_risk_assessment, :completed, move: move }

  before do
    create(:notification_type, :webhook)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  context 'when notifying about a youth risk assessment' do
    it 'creates a webhook notification record' do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end

    it 'does not create an email notification record' do
      expect { perform }.not_to change(Notification.emails, :count)
    end

    it 'schedules NotifyWebhookJob' do
      perform
      expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.webhooks.last.id, queue_as: :some_queue_name)
    end

    it 'does not schedule a NotifyEmailJob' do
      perform
      expect(NotifyEmailJob).not_to have_received(:perform_later)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrepareMoveNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(topic_id: move.id, action_name: action_name, queue_as: :some_queue_name, send_webhooks: send_webhooks, send_emails: send_emails, only_supplier_id: only_supplier_id)
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: supplier }
  let(:action_name) { 'create' }
  let(:send_webhooks) { true }
  let(:send_emails) { true }
  let(:only_supplier_id) { nil }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  shared_examples_for 'it creates a webhook notification record' do
    it do
      expect { perform }.to change(Notification.webhooks, :count).by(1)
    end
  end

  shared_examples_for 'it does not create a webhook notification record' do
    it do
      expect { perform }.not_to change(Notification.webhooks, :count)
    end
  end

  shared_examples_for 'it creates an email notification record' do
    it do
      expect { perform }.to change(Notification.emails, :count).by(1)
    end
  end

  shared_examples_for 'it does not create an email notification record' do
    it do
      expect { perform }.not_to change(Notification.emails, :count)
    end
  end

  shared_examples_for 'it schedules NotifyWebhookJob' do
    before { perform }

    it { expect(NotifyWebhookJob).to have_received(:perform_later).with(notification_id: Notification.webhooks.last.id, queue_as: :some_queue_name) }
  end

  shared_examples_for 'it does not schedule NotifyWebhookJob' do
    before { perform }

    it { expect(NotifyWebhookJob).not_to have_received(:perform_later) }
  end

  shared_examples_for 'it schedules NotifyEmailJob' do
    before { perform }

    it { expect(NotifyEmailJob).to have_received(:perform_later).with(notification_id: Notification.emails.last.id, queue_as: :some_queue_name) }
  end

  shared_examples_for 'it does not schedule NotifyEmailJob' do
    before { perform }

    it { expect(NotifyEmailJob).not_to have_received(:perform_later) }
  end

  context 'when creating a move' do
    context 'when a subscription has both a webhook and email addresses' do
      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it creates an email notification record'
      it_behaves_like 'it schedules NotifyWebhookJob'
      it_behaves_like 'it schedules NotifyEmailJob'
    end

    context 'when a subscription has no email addresses' do
      let(:subscription) { create :subscription, :no_email_address }

      it_behaves_like 'it creates a webhook notification record'
      it_behaves_like 'it does not create an email notification record'
      it_behaves_like 'it schedules NotifyWebhookJob'
      it_behaves_like 'it does not schedule NotifyEmailJob'
    end

    context 'when a subscription has no webhook' do
      let(:subscription) { create :subscription, :no_callback_url }

      it_behaves_like 'it does not create a webhook notification record'
      it_behaves_like 'it creates an email notification record'
      it_behaves_like 'it schedules NotifyEmailJob'
      it_behaves_like 'it does not schedule NotifyWebhookJob'
    end
  end

  context 'when confirming a person escort record' do
    let(:action_name) { 'confirm_person_escort_record' }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when creating a back-dated move' do
    let(:move) { create :move, from_location: location, date: 2.days.ago, supplier: supplier }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it does not create an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it does not schedule NotifyEmailJob'
  end

  context 'when creating a move for today' do
    let(:move) { create :move, from_location: location, date: Time.zone.today, supplier: supplier }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when creating a forward-dated move' do
    let(:move) { create :move, from_location: location, date: 2.days.from_now, supplier: supplier }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when creating a proposed move' do
    let(:move) { create :move, :proposed, from_location: location, date_from: Time.zone.today, supplier: supplier }

    it_behaves_like 'it does not create a webhook notification record'
    it_behaves_like 'it does not create an email notification record'
    it_behaves_like 'it does not schedule NotifyWebhookJob'
    it_behaves_like 'it does not schedule NotifyEmailJob'
  end

  context 'when send_webhooks is false' do
    let(:send_webhooks) { false }

    it_behaves_like 'it does not create a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it does not schedule NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when send_emails is false' do
    let(:send_emails) { false }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it does not create an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it does not schedule NotifyEmailJob'
  end

  context 'when only_supplier_id matches the move supplier' do
    let(:only_supplier_id) { supplier.id }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when only_supplier_id does not match the move supplier' do
    let(:only_supplier_id) { create(:supplier).id }

    it_behaves_like 'it does not create a webhook notification record'
    it_behaves_like 'it does not create an email notification record'
    it_behaves_like 'it does not schedule NotifyWebhookJob'
    it_behaves_like 'it does not schedule NotifyEmailJob'
  end
end

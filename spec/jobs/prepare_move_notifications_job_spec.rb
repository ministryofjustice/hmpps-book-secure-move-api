# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrepareMoveNotificationsJob, type: :job do
  subject(:perform) do
    described_class.perform_now(topic_id: move.id, action_name:, queue_as: :some_queue_name, send_webhooks:, send_emails:, only_supplier_id:)
  end

  let(:subscription) { create :subscription }
  let(:supplier) { create :supplier, name: 'test', subscriptions: [subscription] }
  let(:location) { create :location, suppliers: [supplier] }
  let(:move) { create :move, from_location: location, supplier: }
  let(:action_name) { 'create' }
  let(:send_webhooks) { true }
  let(:send_emails) { true }
  let(:only_supplier_id) { nil }
  let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: 'geoamey,serco' } }

  before do
    create(:notification_type, :webhook)
    create(:notification_type, :email)

    allow(NotifyWebhookJob).to receive(:perform_later)
    allow(NotifyEmailJob).to receive(:perform_later)
  end

  around do |example|
    ClimateControl.modify(**envs) do
      example.run
    end
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

    context 'when it is a cross-supplier move' do
      let!(:initial_supplier) { create(:supplier, :serco) }
      let!(:receiving_supplier) { create(:supplier, :geoamey) }
      let!(:subscription) { create(:subscription, :no_email_address, supplier: initial_supplier) }
      let!(:subscription2) { create(:subscription, :no_email_address, supplier: receiving_supplier) }
      let(:to_location) { create :location, :court, suppliers: [receiving_supplier] }
      let(:move) { create :move, from_location: location, to_location:, supplier: }

      it 'sends the create_move and cross_supplier_move_add notifications to the respective suppliers' do
        perform
        expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to contain_exactly(
          [subscription.id, 'create_move'],
          [subscription2.id, 'cross_supplier_move_add'],
        )
      end

      context 'when the feature flag is not set' do
        let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: '' } }

        it 'only sends the create_move notification to the initial supplier' do
          perform
          expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to contain_exactly(
            [subscription.id, 'create_move'],
          )
        end
      end
    end
  end

  context 'when updating a move' do
    let(:action_name) { 'update' }

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

    context 'when it is updated to become a cross-supplier move' do
      let!(:initial_supplier) { create(:supplier, :serco) }
      let!(:receiving_supplier) { create(:supplier, :geoamey) }
      let!(:subscription) { create(:subscription, :no_email_address, supplier: initial_supplier) }
      let!(:subscription2) { create(:subscription, :no_email_address, supplier: receiving_supplier) }
      let(:to_location) { create :location, :court, suppliers: [receiving_supplier] }
      let(:move) { create :move, from_location: location, to_location:, supplier: }

      it 'sends the update_move and cross_supplier_move_add notifications to the respective suppliers' do
        perform
        expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to contain_exactly(
          [subscription.id, 'update_move'],
          [subscription2.id, 'cross_supplier_move_add'],
        )
      end

      context 'when the feature flag is not set' do
        let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: '' } }

        it 'only sends the update_move notification to the initial supplier' do
          perform
          expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to contain_exactly(
            [subscription.id, 'update_move'],
          )
        end
      end
    end

    context 'when it is a cross-supplier move that has already been notified' do
      let!(:initial_supplier) { create(:supplier, :serco) }
      let!(:receiving_supplier) { create(:supplier, :geoamey) }
      let!(:subscription) { create(:subscription, :no_email_address, supplier: initial_supplier) }
      let!(:subscription2) { create(:subscription, :no_email_address, supplier: receiving_supplier) }
      let(:to_location) { create :location, :court, suppliers: [receiving_supplier] }
      let(:move) { create :move, from_location: location, to_location:, supplier: }
      let!(:existing_notification) { create(:notification, event_type: 'cross_supplier_move_add', topic: move, subscription: subscription2) }

      it 'sends the update_move and cross_supplier_move_update notifications to the suppliers' do
        perform
        expect(
          Notification.webhooks.order(:created_at).where.not(event_type: 'cross_supplier_move_add').pluck(:subscription_id, :event_type),
        ).to contain_exactly(
          [subscription.id, 'update_move'],
          [subscription2.id, 'cross_supplier_move_update'],
        )
      end

      context 'when the feature flag is not set' do
        let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: '' } }

        it 'only sends the update_move notification to the initial supplier' do
          perform
          expect(
            Notification.webhooks.order(:created_at).where.not(event_type: 'cross_supplier_move_add').pluck(:subscription_id, :event_type),
          ).to contain_exactly(
            [subscription.id, 'update_move'],
          )
        end
      end
    end
  end

  context 'when updating move status' do
    let(:action_name) { 'update_status' }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'

    context 'when a create_move notification has not already been sent' do
      it 'sends the notification as create_move' do
        perform
        expect(Notification.webhooks.order(:created_at).last.event_type).to eq('create_move')
      end
    end

    context 'when a create_move notification has already been sent' do
      before do
        subscription.notifications.create!(
          notification_type_id: :webhook, topic: move, event_type: 'create_move',
        )
      end

      it 'sends the notification as update_move_status' do
        perform
        expect(Notification.webhooks.order(:created_at).last.event_type).to eq('update_move_status')
      end
    end
  end

  context 'when cancelling a move' do
    let(:action_name) { 'update_status' }

    before { move.cancel!(cancellation_reason: Move::CANCELLATION_REASON_OTHER) }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'

    context 'when a create_move notification has not already been sent' do
      it 'sends the notification as update_move_status' do
        perform
        expect(Notification.webhooks.order(:created_at).last.event_type).to eq('update_move_status')
      end
    end

    context 'when a create_move notification has already been sent' do
      before do
        subscription.notifications.create!(
          notification_type_id: :webhook, topic: move, event_type: 'create_move',
        )
      end

      it 'sends the notification as update_move_status' do
        perform
        expect(Notification.webhooks.order(:created_at).last.event_type).to eq('update_move_status')
      end
    end
  end

  context 'when explicitly notifying a cross-supplier move' do
    let(:action_name) { 'cross_supplier_add' }
    let!(:initial_supplier) { create(:supplier, :serco) }
    let!(:receiving_supplier) { create(:supplier, :geoamey) }
    let!(:subscription) { create(:subscription, :no_email_address, supplier: initial_supplier) }
    let!(:subscription2) { create(:subscription, :no_email_address, supplier: receiving_supplier) }
    let(:to_location) { create :location, :court, suppliers: [receiving_supplier] }
    let(:move) { create :move, from_location: location, to_location:, supplier: }

    it 'sends the cross_supplier_move_add notification only to the receiving supplier' do
      perform
      expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to contain_exactly(
        [subscription2.id, 'cross_supplier_move_add'],
      )
    end

    context 'when the feature flag is not set' do
      let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: '' } }

      it 'does not notify the receiving supplier' do
        perform
        expect(Notification.webhooks.order(:created_at).pluck(:subscription_id, :event_type)).to be_empty
      end
    end
  end

  context 'when explicitly notifying that a move is no longer cross-supplier' do
    let(:action_name) { 'cross_supplier_remove' }
    let!(:initial_supplier) { create(:supplier, :serco) }
    let!(:receiving_supplier) { create(:supplier, :geoamey) }
    let!(:subscription) { create(:subscription, :no_email_address, supplier: initial_supplier) }
    let!(:subscription2) { create(:subscription, :no_email_address, supplier: receiving_supplier) }
    let(:to_location) { create :location, :court, suppliers: [receiving_supplier] }
    let(:move) { create :move, from_location: location, to_location:, supplier: }
    let!(:notification) { create(:notification, :webhook, event_type: 'cross_supplier_move_add', subscription: subscription2, topic: move) }

    it 'sends the cross_supplier_move_remove notification only to the supplier who received the cross_supplier_move_add' do
      perform
      expect(Notification.webhooks.where.not(event_type: 'cross_supplier_move_add').pluck(:subscription_id, :event_type))
        .to contain_exactly([subscription2.id, 'cross_supplier_move_remove'])
    end

    context 'when the feature flag is not set' do
      let(:envs) { { FEATURE_FLAG_CROSS_SUPPLIER_NOTIFICATIONS_SUPPLIERS: '' } }

      it 'does not notify the receiving supplier' do
        perform
        expect(Notification.webhooks.where.not(event_type: 'cross_supplier_move_add').pluck(:subscription_id, :event_type)).to be_empty
      end
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
    let(:move) { create :move, from_location: location, date: 2.days.ago, supplier: }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it does not create an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it does not schedule NotifyEmailJob'
  end

  context 'when creating a move for today' do
    let(:move) { create :move, from_location: location, date: Time.zone.today, supplier: }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when creating a forward-dated move' do
    let(:move) { create :move, from_location: location, date: 2.days.from_now, supplier: }

    it_behaves_like 'it creates a webhook notification record'
    it_behaves_like 'it creates an email notification record'
    it_behaves_like 'it schedules NotifyWebhookJob'
    it_behaves_like 'it schedules NotifyEmailJob'
  end

  context 'when creating a proposed move' do
    let(:move) { create :move, :proposed, from_location: location, date_from: Time.zone.today, supplier: }

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

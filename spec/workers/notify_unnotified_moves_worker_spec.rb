require 'rails_helper'

RSpec.describe NotifyUnnotifiedMovesWorker, type: :worker do
  subject(:worker) { described_class.new }

  let(:supplier) { create(:supplier) }
  let(:subscription) { create(:subscription, callback_url: 'https://foo.bar/', supplier:) }

  let!(:unnotified1) { create(:move, date: Time.zone.today, reference: 'TEST1', supplier:) }
  let!(:unnotified2) { create(:move, :proposed, date: Time.zone.today, reference: 'TEST2', supplier:) }
  let!(:notified1) { create(:move, date: Time.zone.today, reference: 'TEST4', supplier:) }
  let!(:notified2) { create(:move, date: Time.zone.tomorrow, reference: 'TEST5', supplier:) }

  before do
    create(:move, date: Time.zone.tomorrow, reference: 'TEST3', supplier:)

    allow(Rails).to receive(:logger).and_return(instance_spy(logger))

    GenericEvent::MoveRequested.create!(
      eventable: unnotified1,
      occurred_at: unnotified1.created_at,
      recorded_at: Time.zone.now,
      notes: 'Automatically generated event',
      details: {},
    )
    create(:notification, :webhook, subscription:, topic: notified1, event_type: 'create_move')
    create(:notification, :webhook, subscription:, topic: notified2, event_type: 'update_move_status')

    unnotified2.status = 'requested'
    unnotified2.save!
  end

  it 'only creates notifications for unnotified moves' do
    worker.perform

    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating GenericEvent::MoveRequested event for move TEST1')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created GenericEvent::MoveRequested event for move TEST1')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating create notifications for move TEST1')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created create notifications for move TEST1')

    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating GenericEvent::MoveProposed event for move TEST2')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created GenericEvent::MoveProposed event for move TEST2')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating update_status notifications for move TEST2')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created update_status notifications for move TEST2')

    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating GenericEvent::MoveRequested event for move TEST3')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created GenericEvent::MoveRequested event for move TEST3')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating create notifications for move TEST3')
    expect(Rails.logger).to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created create notifications for move TEST3')

    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating GenericEvent::MoveRequested event for move TEST4')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created GenericEvent::MoveRequested event for move TEST4')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating create notifications for move TEST4')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created create notifications for move TEST4')

    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating GenericEvent::MoveRequested event for move TEST5')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created GenericEvent::MoveRequested event for move TEST5')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Creating create notifications for move TEST5')
    expect(Rails.logger).not_to have_received(:info).with('[NotifyUnnotifiedMovesWorker] Created create notifications for move TEST5')
  end
end

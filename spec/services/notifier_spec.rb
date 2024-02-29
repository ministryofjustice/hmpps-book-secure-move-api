# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  include ActiveJob::TestHelper
  subject { described_class }

  let(:action_name) { 'create' }

  before do
    described_class.prepare_notifications(topic:, action_name:)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when scheduled with a generic_event' do
    let(:move) { create(:move, date: Time.zone.tomorrow) }
    let(:topic) { create(:event_person_move_assault, eventable: move) }
    let(:action_name) { 'create_event' }

    it 'queues a job' do
      expect(PrepareGenericEventNotificationsJob)
        .to have_been_enqueued
        .with(topic_id: topic.id, action_name:, send_emails: false, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a move for today' do
    let(:topic) { create(:move, date: Time.zone.today) }

    it 'queues a job with high priority' do
      expect(PrepareMoveNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, queue_as: :notifications_high)
    end
  end

  context 'when scheduled with a move for tomorrow' do
    let(:topic) { create(:move, date: Time.zone.tomorrow) }

    it 'queues a job medium priority' do
      expect(PrepareMoveNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a move for next week' do
    let(:topic) { create(:move, date: Time.zone.today + 7) }

    it 'queues a job with low priority' do
      expect(PrepareMoveNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, queue_as: :notifications_low)
    end
  end

  context 'when scheduled with a person' do
    let(:topic) { create(:person) }

    it 'queues a job with medium priority' do
      expect(PreparePersonNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a profile' do
    let(:topic) { create(:profile) }

    it 'queues a job' do
      expect(PrepareProfileNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a person_escort_record amendment' do
    let(:move) { create(:move, date: Time.zone.tomorrow) }
    let(:topic) { create(:person_escort_record, move:) }
    let(:action_name) { 'amend_person_escort_record' }

    it 'queues a job' do
      expect(PreparePersonEscortRecordNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, send_emails: true, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with another person_escort_record action' do
    let(:move) { create(:move, date: Time.zone.tomorrow) }
    let(:topic) { create(:person_escort_record, move:) }

    it 'queues a job' do
      expect(PreparePersonEscortRecordNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, send_emails: false, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a youth_risk_assessment' do
    let(:location) { create(:location, :stc) }
    let(:move) { create(:move, from_location: location, date: Time.zone.tomorrow) }
    let(:topic) { create(:youth_risk_assessment, move:) }

    it 'queues a job' do
      expect(PrepareYouthRiskAssessmentNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name:, send_emails: false, queue_as: :notifications_medium)
    end
  end

  context 'when scheduled with a lodging' do
    let(:topic) { create(:lodging) }

    it 'queues a job' do
      expect(PrepareLodgingNotificationsJob)
        .to have_been_enqueued
        .with(topic_id: topic.id, action_name:, queue_as: :notifications_medium)
    end
  end

  context 'when called with another object' do
    let(:topic) { Object.new }

    it 'does not queue a job' do
      expect(PrepareMoveNotificationsJob).not_to have_been_enqueued
    end
  end
end

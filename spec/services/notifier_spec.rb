# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  include ActiveJob::TestHelper
  subject { described_class }

  let(:action_name) { 'create' }

  before do
    described_class.prepare_notifications(topic: topic, action_name: action_name)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when scheduled with a move' do
    let(:topic) { create(:move) }

    it 'queues a job' do
      expect(PrepareMoveNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name: action_name)
    end
  end

  context 'when scheduled with a person' do
    let(:topic) { create(:person) }

    it 'queues a job' do
      expect(PreparePersonNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name: action_name)
    end
  end

  context 'when scheduled with a person_escort_record' do
    let(:topic) { create(:person_escort_record) }

    it 'queues a job' do
      expect(PreparePersonEscortRecordNotificationsJob).to have_been_enqueued.with(topic_id: topic.id, action_name: action_name)
    end
  end

  context 'when called with another object' do
    let(:topic) { Object.new }

    it 'doesn\'t queue a job' do
      expect(PrepareMoveNotificationsJob).not_to have_been_enqueued
    end
  end
end

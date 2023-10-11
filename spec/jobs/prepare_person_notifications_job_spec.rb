# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreparePersonNotificationsJob, type: :job do
  let(:person) { create :person }
  let!(:move_today) { create :move, profile: person.latest_profile, date: Time.zone.today }
  let!(:move_next_week) { create :move, profile: person.latest_profile, date: Time.zone.today + 7 }
  let!(:other_move) { create :move, date: Time.zone.tomorrow }

  before do
    allow(PrepareMoveNotificationsJob).to receive(:perform_now)
    described_class.perform_now(topic_id: person.id, action_name:)
  end

  shared_examples 'it calls PrepareMoveNotificationsJob for the related moves' do
    it { expect(PrepareMoveNotificationsJob).to have_received(:perform_now).once.with(topic_id: move_today.id, action_name:, queue_as: :notifications_high) }
    it { expect(PrepareMoveNotificationsJob).to have_received(:perform_now).once.with(topic_id: move_next_week.id, action_name:, queue_as: :notifications_low) }
    it { expect(PrepareMoveNotificationsJob).not_to have_received(:perform_now).with(topic_id: other_move.id, action_name:, queue_as: :notifications_medium) }
  end

  # NB: we are testing here that creating a person and updating a person behave in the same way from the perspective of PreparePersonNotificationsJob.
  # NB: note however that the PeopleController however does not call PreparePersonNotificationsJob on creating a person, to reduce duplicate emails.
  context 'when creating a person' do
    let(:action_name) { 'create' }

    it_behaves_like 'it calls PrepareMoveNotificationsJob for the related moves'
  end

  context 'when updating a person' do
    let(:action_name) { 'update' }

    it_behaves_like 'it calls PrepareMoveNotificationsJob for the related moves'
  end
end

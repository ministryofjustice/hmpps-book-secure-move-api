# frozen_string_literal: true

RSpec.describe PrepareProfileNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: profile.id, action_name: action_name) }

  let(:person) { create(:person) }
  let(:profile) { create :profile, person: person }
  let(:other_profile) { create :profile, person: person }

  let!(:move1) { create :move, profile: profile }
  let!(:move2) { create :move, profile: profile }
  let!(:other_move) { create :move, profile: other_profile }

  before do
    allow(PrepareMoveNotificationsJob).to receive(:perform_now)
    perform
  end

  shared_examples 'it calls PrepareMoveNotificationsJob for the related moves' do
    it { expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move1.id, action_name: action_name) }
    it { expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move2.id, action_name: action_name) }
    it { expect(PrepareMoveNotificationsJob).not_to have_received(:perform_now).with(topic_id: other_move.id, action_name: action_name) }
  end

  # NB: we are testing here that creating a person and updating a person behave in the same way from the perspective of PreparePersonNotificationsJob.
  # NB: note however that the PeopleController however does not call PreparePersonNotificationsJob on creating a person, to reduce duplicate emails.
  context 'when creating a profile' do
    let(:action_name) { 'create' }

    it_behaves_like 'it calls PrepareMoveNotificationsJob for the related moves'
  end

  context 'when updating a profile' do
    let(:action_name) { 'update' }

    it_behaves_like 'it calls PrepareMoveNotificationsJob for the related moves'
  end
end

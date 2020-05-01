# frozen_string_literal: true

RSpec.describe PreparePersonNotificationsJob, type: :job do
  subject(:perform) { described_class.new.perform(topic_id: person.id, action_name: action_name) }

  let(:person) { create :person }
  let!(:move1) { create :move, person: person }
  let!(:move2) { create :move,  person: person }
  let!(:other_move) { create :move }

  before do
    allow(PrepareMoveNotificationsJob).to receive(:perform_now)
    perform
  end

  context 'when updating a person' do
    let(:action_name) { 'update' }

    it 'calls PrepareMoveNotificationsJob for the related moves but not for the unrelated moves' do
      expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move1.id, action_name: action_name)
      expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move2.id, action_name: action_name)
      expect(PrepareMoveNotificationsJob).not_to have_received(:perform_now).with(topic_id: other_move.id, action_name: action_name)
    end

  end

  context 'when creating a person' do
    let(:action_name) { 'create' }

    it 'calls PrepareMoveNotificationsJob for the related moves but not for the unrelated moves' do
      expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move1.id, action_name: action_name)
      expect(PrepareMoveNotificationsJob).to have_received(:perform_now).with(topic_id: move2.id, action_name: action_name)
      expect(PrepareMoveNotificationsJob).not_to have_received(:perform_now).with(topic_id: other_move.id, action_name: action_name)
    end
  end
end

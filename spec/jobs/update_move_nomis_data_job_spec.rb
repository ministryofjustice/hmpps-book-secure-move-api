# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateMoveNomisDataJob, type: :job do
  subject(:perform) do
    described_class.perform_now(move_id: move_id)
  end

  let(:move) { create :move }
  let(:move_id) { move.id }

  before do
    allow(move.person).to receive(:update_nomis_data) if move.person
    allow(Move).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
    allow(Move).to receive(:find).with(move.id).and_return(move)
    allow(Notifier).to receive(:prepare_notifications)
  end

  context 'with an associated person' do
    before { perform }

    it 'updates NOMIS data for the person' do
      expect(move.person).to have_received(:update_nomis_data)
    end

    it 'sends an update_move notification' do
      expect(Notifier)
        .to have_received(:prepare_notifications)
        .with(topic: move, action_name: 'update')
    end
  end

  context 'without an associated person' do
    before { perform }

    let(:move) { create(:move, person: nil) }

    it 'does not send an update_move notification' do
      expect(Notifier).not_to have_received(:prepare_notifications)
    end
  end

  context 'when the move is not found' do
    let(:move_id) { 'bad-id' }

    it 'bubbles up the error' do
      expect { perform }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the NOMIS call raises an error' do
    let(:error) { OAuth2::Error.new(instance_double(OAuth2::Response)) }

    before do
      allow(move.person)
        .to receive(:update_nomis_data)
        .and_raise(error)
    end

    it 'bubbles up the error' do
      expect { perform }.to raise_error(error)
    end
  end
end

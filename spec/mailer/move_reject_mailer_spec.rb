# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveRejectMailer, type: :mailer do
  subject(:mail) { described_class.notify(email, move, move_reject_event) }

  let(:email) { 'move-booker@example.com' }
  let(:move) { create(:move, reference: 'MOVEREF2') }
  let(:move_reject_event) { create(:event_move_reject, eventable: move, details: { rejection_reason: 'no_transport_available', cancellation_reason_comment: 'It was a mistake', rebook: rebook }) }
  let(:rebook) { false }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_MOVE_REJECT_TEMPLATE_ID', nil).and_return('reject-template-id')
  end

  describe 'to' do
    it { expect(mail.to).to match_array('move-booker@example.com') }
  end

  describe 'govuk_notify_template' do
    it { expect(mail.govuk_notify_template).to eql('reject-template-id') }
  end

  describe 'govuk_notify_reference' do
    it { expect(mail.govuk_notify_reference).to eql(move.reference) }
  end

  describe 'govuk_notify_personalisation' do
    subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

    it { is_expected.to include('move-reference': 'MOVEREF2') }
    it { is_expected.to include('move-id': move.id) }
    it { is_expected.to include('from-location': move.from_location.title) }
    it { is_expected.to include('to-location': move.to_location.title) }
    it { is_expected.to include('rejection-reason': 'no transport is available for this move') }
    it { is_expected.to include('move-rebooked': false) }
    it { is_expected.to include('move-not-rebooked': true) }
  end

  context 'when move is rebooked' do
    let(:rebook) { true }

    describe 'govuk_notify_personalisation' do
      subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

      it { is_expected.to include('move-rebooked': true) }
      it { is_expected.to include('move-not-rebooked': false) }
    end
  end

  describe 'rejection_reason_description' do
    subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

    let(:move_reject_event) { create(:event_move_reject, eventable: move, rejection_reason: rejection_reason) }

    context 'when rejection reason is no_space_at_receiving_prison' do
      let(:rejection_reason) { 'no_space_at_receiving_prison' }

      it { is_expected.to include('rejection-reason': "there are no spaces at #{move.to_location.title} on the dates you requested.") }
    end

    context 'when rejection reason is no_transport_available' do
      let(:rejection_reason) { 'no_transport_available' }

      it { is_expected.to include('rejection-reason': 'no transport is available for this move') }
    end
  end
end

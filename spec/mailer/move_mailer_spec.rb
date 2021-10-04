# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveMailer, type: :mailer do
  subject(:mail) { described_class.notify(notification) }

  let(:supplier) { create(:supplier, name: 'Test Supplier') }
  let(:subscription) { create(:subscription, supplier: supplier, email_address: 'user@foo.bar') }
  let(:notification) { create(:notification, :email, subscription: subscription, topic: move) }
  let(:move) { create(:move, reference: 'MOVEREF1', status: Move::MOVE_STATUS_REQUESTED) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GOVUK_NOTIFY_MOVE_TEMPLATE_ID', nil).and_return('some-template-id')
    allow(ENV).to receive(:fetch).with('SERVER_FQDN', Rails.env).and_return('www.example.org')
  end

  describe 'to' do
    it { expect(mail.to).to match_array('user@foo.bar') }
  end

  describe 'govuk_notify_template' do
    it { expect(mail.govuk_notify_template).to eql('some-template-id') }
  end

  describe 'govuk_notify_reference' do
    it { expect(mail.govuk_notify_reference).to eql(notification.id) }
  end

  describe 'govuk_notify_personalisation' do
    subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

    it { is_expected.to include('move-reference': 'MOVEREF1') }
    it { is_expected.to include('from-location': move.from_location.title) }
    it { is_expected.to include('to-location': move.to_location.title) }
    it { is_expected.to include('move-date': move.date.strftime('%d/%m/%Y')) }
    it { is_expected.to include('move-date-from': move.date_from.strftime('%d/%m/%Y')) }
    it { is_expected.to include('move-date-to': 'N/A') }
    it { is_expected.to include('move-created-at': move.created_at.strftime('%d/%m/%Y %T')) }
    it { is_expected.to include('move-updated-at': move.updated_at.strftime('%d/%m/%Y %T')) }
    it { is_expected.to include('move-action': 'requested') }
    it { is_expected.to include('move-status': 'requested') }
    it { is_expected.to include('environment': 'www.example.org') }
    it { is_expected.to include('supplier': 'Test Supplier') }
  end

  context 'when move is a prison recall' do
    let(:move) { create(:move, :prison_recall, :requested) }

    describe 'govuk_notify_personalisation' do
      subject(:govuk_notify_personalisation) { mail.govuk_notify_personalisation }

      it { is_expected.to include('move-reference': move.reference) }
      it { is_expected.to include('from-location': move.from_location.title) }
      it { is_expected.to include('to-location': 'N/A') }
      it { is_expected.to include('move-created-at': move.created_at.strftime('%d/%m/%Y %T')) }
      it { is_expected.to include('move-updated-at': move.updated_at.strftime('%d/%m/%Y %T')) }
      it { is_expected.to include('move-action': 'requested') }
      it { is_expected.to include('move-status': 'requested') }
      it { is_expected.to include('environment': 'www.example.org') }
      it { is_expected.to include('supplier': 'Test Supplier') }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to validate_presence_of :supplier }

  describe 'email_address or callback_url (or both) are required' do
    context 'when no callback_url' do
      subject { build(:subscription, :no_callback_url) }

      it { is_expected.to be_valid }
    end

    context 'when no email_address' do
      subject { build(:subscription, :no_email_address) }

      it { is_expected.to be_valid }
    end

    context 'when no email_address and no callback_url' do
      subject { build(:subscription, :no_email_address, :no_callback_url) }

      it { is_expected.not_to be_valid }
    end

    context 'when email_address and callback_url provided' do
      subject { build(:subscription, email_address: 'foo@example.org', callback_url: 'https://foo.bar/') }

      it { is_expected.to be_valid }
    end
  end

  describe 'callback_url' do
    subject { build(:subscription, callback_url: url) }

    context 'when invalid url' do
      let(:url) { 'foo bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when valid url' do
      let(:url) { 'http://bar:1234/foo/bar/?foo=bar' }

      it { is_expected.to be_valid }
    end
  end

  describe 'email_address' do
    subject { build(:subscription, email_address: email_address) }

    context 'when invalid email_address' do
      let(:email_address) { 'foo bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when valid email_address' do
      let(:email_address) { 'foo@example.org' }

      it { is_expected.to be_valid }
    end
  end

  describe 'secret' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.secret).to eq('Secret') }
    end
  end

  describe 'encrypted_secret' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.encrypted_secret).not_to eq('Secret') }
    end
  end

  describe 'username' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.username).to eq('username') }
    end
  end

  describe 'encrypted_username' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.encrypted_username).not_to eq('username') }
    end
  end

  describe 'password' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.password).to eq('password') }
    end
  end

  describe 'encrypted_password' do
    subject(:subscription) { build(:subscription) }

    context 'when writing' do
      it { expect(subscription.encrypted_password).not_to eq('password') }
    end
  end

  describe 'kept?' do
    subject(:subscription) { build(:subscription, discarded_at: discarded_at) }

    context 'when subscription is discarded' do
      let(:discarded_at) { Time.zone.now }

      it { expect(subscription.kept?).to be false }
    end

    context 'when subscription is not discarded' do
      let(:discarded_at) { nil }

      it { expect(subscription.kept?).to be true }
    end
  end
end

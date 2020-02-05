# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to validate_presence_of :supplier }
  it { is_expected.to validate_presence_of :callback_url }

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

  describe 'secret' do
    subject(:subscription) { create(:subscription) }

    context 'when writing' do
      it { expect(subscription.secret).to eq('Secret') }
    end
  end

  describe 'encrypted_secret' do
    subject(:subscription) { create(:subscription) }

    context 'when writing' do
      it { expect(subscription.encrypted_secret).not_to eq('Secret') }
    end
  end
end

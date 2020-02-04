# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  it { is_expected.to have_many(:notifications) }

  subject { build(:subscription) }

  describe 'callback' do
    subject { build(:subscription, callback: callback) }
    context 'invalid url' do
      let(:callback) { 'foo bar' }
      it { is_expected.to_not be_valid }
    end

    context 'valid url' do
      let(:callback) { 'http://bar:1234/foo/bar/?foo=bar' }
      it { is_expected.to be_valid }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JourneyEvents::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:params) { { type: type, attributes: { timestamp: timestamp } } }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }
  let(:type) { 'redirects' }

  context 'when valid' do
    it { is_expected.to be_valid }
  end

  describe 'cancellation_reason' do
    let(:type) { 'cancel' }

    context 'when invalid' do
      let(:cancellation_reason) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:cancellation_reason) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { params.delete(:cancellation_reason) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'rejection_reason' do
    let(:type) { 'reject' }

    context 'when invalid' do
      let(:rejection_reason) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:rejection_reason) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { params.delete(:rejection_reason) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'type' do
    context 'when invalid' do
      let(:type) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:type) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { params.delete(:type) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'timestamp' do
    context 'when invalid' do
      let(:timestamp) { '1/2/20 8pm' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:timestamp) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { params[:attributes].delete(:timestamp) }

      it { is_expected.not_to be_valid }
    end
  end
end

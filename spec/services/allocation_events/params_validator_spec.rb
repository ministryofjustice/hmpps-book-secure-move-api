# frozen_string_literal: true

# TODO: remove file completely when allocation `events` endpoint is no longer in use
require 'rails_helper'

RSpec.describe AllocationEvents::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:params) { { attributes: { event_name: event_name, timestamp: timestamp } } }
  let(:event_name) { 'cancel' }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }

  context 'when valid' do
    it { is_expected.to be_valid }
  end

  describe 'event_name' do
    context 'when invalid' do
      let(:event_name) { 'foo' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:event_name) { nil }

      it { is_expected.to be_valid }
    end

    context 'when missing' do
      before { params[:attributes].delete(:event_name) }

      it { is_expected.to be_valid }
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

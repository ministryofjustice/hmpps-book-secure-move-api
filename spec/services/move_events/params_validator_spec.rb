# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveEvents::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:move) { nil }
  let(:attributes) { { timestamp: } }
  let(:params) { { type:, attributes: } }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }
  let(:type) { 'accepts' }

  context 'when valid' do
    it { is_expected.to be_valid }
  end

  describe 'cancellation_reason' do
    let(:attributes) { { timestamp:, cancellation_reason: } }
    let(:cancellation_reason) { 'supplier_declined_to_move' }
    let(:type) { 'cancel' }

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context 'when invalid' do
      let(:cancellation_reason) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:cancellation_reason) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { attributes.delete(:cancellation_reason) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'rejection_reason' do
    let(:attributes) { { timestamp:, rejection_reason: } }
    let(:rejection_reason) { 'no_transport_available' }
    let(:type) { 'reject' }

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context 'when invalid' do
      let(:rejection_reason) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:rejection_reason) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { attributes.delete(:rejection_reason) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'date' do
    let(:attributes) { { timestamp:, date: } }
    let(:date) { '2020-06-10' }
    let(:type) { 'approve' }

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context 'when invalid' do
      let(:date) { 'foo' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:date) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { attributes.delete(:date) }

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

    context 'with acceptable plural actions' do
      let(:type) { 'completes' }

      it 'converts to singular action' do
        expect(params_validator.type).to eq('complete')
      end

      it { is_expected.to be_valid }
    end

    context 'with expected plural actions' do
      let(:type) { 'lockouts' }

      it 'remains as a plural action' do
        expect(params_validator.type).to eq('lockouts')
      end
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

  describe 'from_location_id' do
    let(:params) { { type:, attributes:, relationships: } }
    let(:relationships) { { from_location: { data: { type: 'locations', id: location_id } } } }
    let(:type) { 'lockouts' }
    let(:location_id) { create(:location).id }

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context 'when invalid' do
      let(:location_id) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:location_id) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { relationships.delete(:from_location) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'to_location_id' do
    let(:move) { build(:move, :prison_recall) }
    let(:params) { { type:, attributes:, relationships: } }
    let(:relationships) { { to_location: { data: { type: 'locations', id: location_id } } } }
    let(:type) { 'redirects' }
    let(:location_id) { create(:location).id }

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context 'when invalid' do
      let(:location_id) { 'foo-bar' }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:location_id) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when missing' do
      before { relationships.delete(:to_location) }

      it { is_expected.not_to be_valid }
    end
  end
end

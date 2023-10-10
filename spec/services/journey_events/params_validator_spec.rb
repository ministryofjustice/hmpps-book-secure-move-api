# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JourneyEvents::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:params) { { type:, attributes: { timestamp: } } }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }

  context 'when type=starts' do
    let(:type) { 'starts' }

    context 'when valid' do
      it { is_expected.to be_valid }
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

  context 'when type=lodgings' do
    let(:type) { 'lodgings' }
    let(:location_id) { create(:location).id }
    let(:params) do
      { type:,
        attributes: { timestamp: },
        relationships: {
          to_location: { data: { type: 'locations', id: location_id } },
        } }
    end

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context "when the location_id doesn't exist" do
      let(:location_id) { 'nowhere' }

      it { is_expected.not_to be_valid }
    end

    context 'when the to_location relationship is missing' do
      before { params[:relationships].delete(:to_location) }

      it { is_expected.not_to be_valid }
    end
  end

  context 'when type=lockouts' do
    let(:type) { 'lockouts' }
    let(:location_id) { create(:location).id }
    let(:params) do
      { type:,
        attributes: { timestamp: },
        relationships: {
          from_location: { data: { type: 'locations', id: location_id } },
        } }
    end

    context 'when valid' do
      it { is_expected.to be_valid }
    end

    context "when the location_id doesn't exist" do
      let(:location_id) { 'nowhere' }

      it { is_expected.not_to be_valid }
    end

    context 'when the from_location relationship is missing' do
      before { params[:relationships].delete(:from_location) }

      it { is_expected.not_to be_valid }
    end
  end
end

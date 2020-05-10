# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journeys::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:billable) { false }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }
  let(:vehicle) { { id: '12345678ABC', registration: 'AB12 CDE' } }
  let(:from_location_id) { 'id-123' }
  let(:to_location_id) { 'id-456' }

  shared_examples('it validates required billable') do
    context 'when invalid' do
      let(:billable) { 'foo' }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when nil' do
      let(:billable) { nil }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:attributes].delete(:billable) }

      it { is_expected.not_to be_valid(validation_context) }
    end
  end

  shared_examples('it validates optional billable') do
    context 'when invalid' do
      let(:billable) { 'foo' }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when nil' do
      let(:billable) { nil }

      it { is_expected.to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:attributes].delete(:billable) }

      it { is_expected.to be_valid(validation_context) }
    end
  end

  shared_examples('it validates timestamp') do
    context 'when invalid' do
      let(:timestamp) { 'foo' }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when nil' do
      let(:timestamp) { nil }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:attributes].delete(:timestamp) }

      it { is_expected.not_to be_valid(validation_context) }
    end
  end

  shared_examples('it validates from_location') do
    context 'when nil' do
      let(:from_location_id) { nil }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:relationships].delete(:from_location) }

      it { is_expected.not_to be_valid(validation_context) }
    end
  end

  shared_examples('it validates to_location') do
    context 'when nil' do
      let(:to_location_id) { nil }

      it { is_expected.not_to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:relationships].delete(:to_location) }

      it { is_expected.not_to be_valid(validation_context) }
    end
  end

  context 'when creating' do
    let(:validation_context) { :create }
    let(:params) {
      { attributes: { billable: billable, timestamp: timestamp, vehicle: vehicle },
                     relationships: { from_location: { data: { id: from_location_id } },
                                      to_location: { data: { id: to_location_id } } } }
    }

    it { is_expected.to be_valid(validation_context) }
    it_behaves_like 'it validates required billable'
    it_behaves_like 'it validates timestamp'
    it_behaves_like 'it validates from_location'
    it_behaves_like 'it validates to_location'

    # NB: there are no validations for vehicle
  end

  context 'when updating' do
    let(:validation_context) { :update }
    # NB: we cannot change a journey's location via update, so from_location and to_location should not be specified
    let(:params) { { attributes: { billable: billable, timestamp: timestamp, vehicle: vehicle } } }

    it { is_expected.to be_valid(validation_context) }
    it_behaves_like 'it validates optional billable'
    it_behaves_like 'it validates timestamp'

    # NB: there are no validations for vehicle
  end
end

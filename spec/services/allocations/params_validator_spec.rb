# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocations::ParamsValidator do
  subject(:params_validator) { described_class.new(filter_params, sort_params) }

  let(:filter_params) { { date_from:, date_to: } }
  let(:sort_params) { { by: 'date', direction: 'asc' } }
  let(:good_date) { '2019-05-05' }
  let(:date_from) { good_date }
  let(:date_to) { good_date }

  context 'with correct dates' do
    it { is_expected.to be_valid }
  end

  context 'with an unparsable date_from' do
    let(:date_from) { 'ABCD-22-15' }

    it { is_expected.not_to be_valid }
  end

  context 'with an unparsable date_to' do
    let(:date_to) { 'YYYY-10-Tu' }

    it { is_expected.not_to be_valid }
  end

  context 'with from_locations only' do
    let(:filter_params) { { from_locations: 'foo' } }

    it { is_expected.to be_valid }
  end

  context 'with to_locations only' do
    let(:filter_params) { { to_locations: 'foo' } }

    it { is_expected.to be_valid }
  end

  context 'with locations only' do
    let(:filter_params) { { locations: 'foo' } }

    it { is_expected.to be_valid }
  end

  context 'with both from_locations and to_locations' do
    let(:filter_params) { { from_locations: 'foo', to_locations: 'bar' } }

    it { is_expected.to be_valid }
  end

  context 'with both from_locations and locations' do
    let(:filter_params) { { from_locations: 'foo', locations: 'bar' } }

    it { is_expected.not_to be_valid }
  end

  context 'with both to_locations and locations' do
    let(:filter_params) { { to_locations: 'foo', locations: 'bar' } }

    it { is_expected.not_to be_valid }
  end

  context 'with from_locations, to_locations and locations' do
    let(:filter_params) { { from_locations: 'foo', to_locations: 'bar', locations: 'baz' } }

    it { is_expected.not_to be_valid }
  end

  context 'without sort details' do
    let(:sort_params) { {} }

    it { is_expected.to be_valid }
  end

  context 'with invalid sort direction' do
    let(:sort_params) { { direction: 'foo' } }

    it { is_expected.not_to be_valid }
  end

  context 'with invalid sort by' do
    let(:sort_params) { { by: 'foo' } }

    it { is_expected.not_to be_valid }
  end
end

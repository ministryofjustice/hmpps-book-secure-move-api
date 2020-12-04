# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Populations::ParamsValidator do
  subject(:params_validator) { described_class.new(date_params, sort_params) }

  let(:date_params) { { date_from: date_from, date_to: date_to } }
  let(:sort_params) { { by: 'title', direction: 'asc' } }
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

  context 'with a nil date_from' do
    let(:date_from) { nil }

    it { is_expected.not_to be_valid }
  end

  context 'with an unparsable date_to' do
    let(:date_to) { 'YYYY-10-Tu' }

    it { is_expected.not_to be_valid }
  end

  context 'with a nil date_to' do
    let(:date_to) { nil }

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

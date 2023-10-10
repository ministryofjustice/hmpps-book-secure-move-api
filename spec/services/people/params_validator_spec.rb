# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::ParamsValidator do
  subject(:params_validator) { described_class.new(filter_params) }

  let(:filter_params) { { date_from:, date_to: } }
  let(:good_date) { '2019-05-05' }

  context 'with correct dates' do
    let(:date_from) { good_date }
    let(:date_to) { '2019-05-06' }

    it { is_expected.to be_valid }
  end

  context 'with an unparsable date_from' do
    let(:date_from) { 'ABCD-22-15' }
    let(:date_to) { good_date }

    it { is_expected.not_to be_valid }
  end

  context 'with an unparsable date_to' do
    let(:date_from) { good_date }
    let(:date_to) { 'YYYY-10-Tu' }

    it { is_expected.not_to be_valid }
  end
end

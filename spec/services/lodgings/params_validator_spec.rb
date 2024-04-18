# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lodgings::ParamsValidator do
  subject(:params_validator) { described_class.new(filter_params) }

  let(:filter_params) { { attributes: { start_date:, end_date: } } }
  let(:good_date) { '2019-05-05' }

  context 'when creating' do
    let(:context) { :create }

    context 'with correct dates' do
      let(:start_date) { good_date }
      let(:end_date) { '2019-05-06' }

      it { is_expected.to be_valid(context) }
    end

    context 'with an unparsable start_date' do
      let(:start_date) { 'ABCD-22-15' }
      let(:end_date) { good_date }

      it { is_expected.not_to be_valid(context) }
    end

    context 'with an unparsable end_date' do
      let(:start_date) { good_date }
      let(:end_date) { 'YYYY-10-Tu' }

      it { is_expected.not_to be_valid(context) }
    end

    context 'with nil start_date' do
      let(:start_date) { nil }
      let(:end_date) { good_date }

      it { is_expected.not_to be_valid(context) }
    end

    context 'with nil end_date' do
      let(:start_date) { good_date }
      let(:end_date) { nil }

      it { is_expected.not_to be_valid(context) }
    end
  end

  context 'when updating' do
    let(:context) { :update }

    context 'with correct dates' do
      let(:start_date) { good_date }
      let(:end_date) { '2019-05-06' }

      it { is_expected.to be_valid(context) }
    end

    context 'with an unparsable start_date' do
      let(:start_date) { 'ABCD-22-15' }
      let(:end_date) { good_date }

      it { is_expected.not_to be_valid(context) }
    end

    context 'with an unparsable end_date' do
      let(:start_date) { good_date }
      let(:end_date) { 'YYYY-10-Tu' }

      it { is_expected.not_to be_valid(context) }
    end

    context 'with nil start_date' do
      let(:start_date) { nil }
      let(:end_date) { good_date }

      it { is_expected.to be_valid(context) }
    end

    context 'with nil end_date' do
      let(:start_date) { good_date }
      let(:end_date) { nil }

      it { is_expected.to be_valid(context) }
    end
  end
end

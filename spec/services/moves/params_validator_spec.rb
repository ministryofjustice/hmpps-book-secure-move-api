# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::ParamsValidator do
  subject(:params_validator) { described_class.new(filter_params, {}) }

  let(:filter_params) { { date_from:, date_to:, date_of_birth_from: date_from, date_of_birth_to: date_to } }
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

  context 'with an empty cancellation reason' do
    let(:filter_params) { { cancellation_reason: } }
    let(:cancellation_reason) { nil }

    it { is_expected.to be_valid }
  end

  context 'with a correct cancellation reason' do
    let(:filter_params) { { cancellation_reason: } }
    let(:cancellation_reason) { 'other' }

    it { is_expected.to be_valid }
  end

  context 'with multiple correct cancellation reasons' do
    let(:filter_params) { { cancellation_reason: } }
    let(:cancellation_reason) { 'other,supplier_declined_to_move' }

    it { is_expected.to be_valid }
  end

  context 'with incorrect cancellation reason' do
    let(:filter_params) { { cancellation_reason: } }
    let(:cancellation_reason) { 'boom' }

    it { is_expected.not_to be_valid }
  end

  context 'with multiple cancellation reasons, and one incorrect' do
    let(:filter_params) { { cancellation_reason: } }
    let(:cancellation_reason) { 'other,i_am_incorrect' }

    it { is_expected.not_to be_valid }
  end

  context 'with an empty rejection reason' do
    let(:filter_params) { { rejection_reason: } }
    let(:rejection_reason) { nil }

    it { is_expected.to be_valid }
  end

  context 'with a correct rejection reason' do
    let(:filter_params) { { rejection_reason: } }
    let(:rejection_reason) { 'no_space_at_receiving_prison' }

    it { is_expected.to be_valid }
  end

  context 'with multiple correct rejection reasons' do
    let(:filter_params) { { rejection_reason: } }
    let(:rejection_reason) { 'no_space_at_receiving_prison,no_transport_available' }

    it { is_expected.to be_valid }
  end

  context 'with incorrect rejection reason' do
    let(:filter_params) { { rejection_reason: } }
    let(:rejection_reason) { 'boom' }

    it { is_expected.not_to be_valid }
  end

  context 'with multiple rejection reasons, and one incorrect' do
    let(:filter_params) { { rejection_reason: } }
    let(:rejection_reason) { 'no_space_at_receiving_prison,i_am_incorrect' }

    it { is_expected.not_to be_valid }
  end
end

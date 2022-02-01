# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journeys::ParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  let(:billable) { false }
  let(:timestamp) { '2020-04-29T22:45:59.000Z' }
  let(:date) { '2020-04-29' }
  let(:params) { { attributes: { billable: billable, timestamp: timestamp, date: date } } }

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

  shared_examples('it validates optional date') do
    context 'when blank' do
      let(:date) { '' }

      it { is_expected.to be_valid(validation_context) }
    end

    context 'when nil' do
      let(:date) { nil }

      it { is_expected.to be_valid(validation_context) }
    end

    context 'when missing' do
      before { params[:attributes].delete(:date) }

      it { is_expected.to be_valid(validation_context) }
    end
  end

  shared_examples('it validates date format') do
    context 'when invalid' do
      let(:date) { 'foo' }

      it { is_expected.not_to be_valid(validation_context) }
    end
  end

  context 'when creating' do
    let(:validation_context) { :create }

    it { is_expected.to be_valid(validation_context) }

    it_behaves_like 'it validates required billable'
    it_behaves_like 'it validates optional date'
    it_behaves_like 'it validates timestamp'
    it_behaves_like 'it validates date format'
  end

  context 'when updating' do
    let(:validation_context) { :update }

    it { is_expected.to be_valid(validation_context) }

    it_behaves_like 'it validates optional billable'
    it_behaves_like 'it validates optional date'
    it_behaves_like 'it validates timestamp'
    it_behaves_like 'it validates date format'
  end
end

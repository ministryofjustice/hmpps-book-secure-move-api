# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::People::IncludeParamsValidator do
  subject(:params_validator) { described_class.new(params) }

  describe 'relationships' do
    context 'with existing relationships' do
      let(:params) { %w[ethnicity gender] }

      it { is_expected.to be_valid }
    end

    context 'with non-existing relationships' do
      let(:params) { %w[foo] }

      it { is_expected.not_to be_valid }
    end

    context 'with mix of existing and non existing relationships' do
      let(:params) { %w[foo gender] }

      it { is_expected.not_to be_valid }
    end

    context 'when nil' do
      let(:params) {}

      it { is_expected.to be_valid }
    end

    context 'when empty' do
      let(:params) { [] }

      it { is_expected.to be_valid }
    end
  end
end

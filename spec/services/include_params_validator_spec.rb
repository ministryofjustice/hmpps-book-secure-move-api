# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IncludeParamsValidator do
  subject(:params_validator) { described_class.new(relationships, supported_relationships) }

  let(:supported_relationships) { %w[ethnicity gender bar person.profiles.flibble] }

  describe '#valid?' do
    context 'with supported relationships' do
      let(:relationships) { %w[ethnicity gender] }

      it { is_expected.to be_valid }
    end

    context 'with explicit unnested relationships' do
      let(:relationships) { %w[person person.profiles] }

      it { is_expected.to be_valid }
    end

    context 'with implicit unnested relationships' do
      let(:relationships) { %w[person.profiles.flibble] }

      it { is_expected.to be_valid }
    end

    context 'with invalid unnested relationships' do
      let(:relationships) { %w[profiles] }

      it { is_expected.not_to be_valid }
    end

    context 'with unsupported relationships' do
      let(:relationships) { %w[foo] }

      it { is_expected.not_to be_valid }
    end

    context 'with mix of supported and unsupported relationships' do
      let(:relationships) { %w[foo gender] }

      it { is_expected.not_to be_valid }
    end

    context 'when relationships are nil' do
      let(:relationships) {}

      it { is_expected.to be_valid }
    end

    context 'when relationships are empty' do
      let(:relationships) { [] }

      it { is_expected.to be_valid }
    end
  end

  describe '#fully_validate!' do
    context 'when valid' do
      let(:relationships) { %w[ethnicity gender] }

      it 'does not propagate an error' do
        expect { params_validator.fully_validate! }.not_to raise_error
      end
    end

    context 'when not valid' do
      let(:relationships) { %w[foo] }
      let(:expected_message) do
        {
          "Bad request": [
            '["foo"] is not supported. Valid values are: ["ethnicity", "gender", "bar", "person", "person.profiles", "person.profiles.flibble"]',
          ],
        }
      end

      it 'propagates a custom validation error' do
        expect { params_validator.fully_validate! }
          .to raise_error(described_class::ValidationError)
      end

      it 'propagates the correct validation error messages' do
        params_validator.fully_validate!
      rescue described_class::ValidationError => e
        expect(e.errors.messages).to eq(expected_message)
      end
    end
  end
end

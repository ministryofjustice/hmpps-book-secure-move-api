# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocation::ComplexCaseAnswer, type: :model do
  subject(:complex_case_answer) { described_class.new(attribute_values) }

  let(:title) { 'test' }
  let(:allocation_complex_case_id) { 'c1913bca-04f2-4688-b372-a547db9a6ce8' }
  let(:attribute_values) do
    {
      title:,
      answer: true,
      allocation_complex_case_id:,
      key: 'just_a_test',
    }
  end

  describe 'validations' do
    context 'without an allocation_complex_case_id' do
      let(:attribute_values) do
        {
          title:,
          answer: true,
        }
      end

      it 'is not valid' do
        expect(complex_case_answer).not_to be_valid
      end
    end

    context 'with an allocation_complex_case_id' do
      let(:attribute_values) do
        {
          allocation_complex_case_id: 123,
        }
      end

      it 'is valid' do
        expect(complex_case_answer).to be_valid
      end
    end
  end

  describe '#as_json' do
    it 'returns a hash of all values' do
      expect(complex_case_answer.as_json).to eql attribute_values.stringify_keys
    end
  end

  describe '#empty?' do
    context 'when :allocation_complex_case_id is missing' do
      let(:allocation_complex_case_id) { '' }

      it 'returns true' do
        expect(complex_case_answer).to be_empty
      end
    end

    context 'when :allocation_complex_case_id is present' do
      it 'returns false' do
        expect(complex_case_answer).not_to be_empty
      end
    end
  end
end

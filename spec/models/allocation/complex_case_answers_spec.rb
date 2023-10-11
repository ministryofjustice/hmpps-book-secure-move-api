# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocation::ComplexCaseAnswers, type: :model do
  subject(:complex_case_answers) { described_class.new(data) }

  let(:title) { 'test' }
  let(:data) do
    [
      {
        title:,
        answer: true,
        allocation_complex_case_id: 123,
      },
      {
        title:,
        answer: false,
        allocation_complex_case_id: 456,
      },
    ]
  end

  describe '#to_a' do
    it 'contains correct number of items' do
      expect(complex_case_answers.to_a.size).to be 2
    end

    it 'converts the items to Allocation::ComplexCaseAnswer objects' do
      expect(complex_case_answers.to_a).to all(be_a Allocation::ComplexCaseAnswer)
    end

    context 'with serialized input' do
      subject(:complex_case_answers) { described_class.new(data.to_json) }

      it 'parses JSON and contains correct number of items' do
        expect(complex_case_answers.to_a.size).to be 2
      end

      it 'parses JSON and converts the items to Allocation::ComplexCaseAnswer objects' do
        expect(complex_case_answers.to_a).to all(be_a Allocation::ComplexCaseAnswer)
      end
    end
  end
end

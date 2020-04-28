# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationSerializer do
  subject(:serializer) { described_class.new(allocation) }


  let(:complex_case) { create(:allocation_complex_case) }
  let(:complex_case_answer_attributes) {
    {
    key: complex_case.key,
    title: complex_case.title,
    answer: true,
    allocation_complex_case_id: complex_case.id,
  }
  }
  let(:complex_case_answer) { Allocation::ComplexCaseAnswer.new(complex_case_answer_attributes) }
  let(:allocation) { create(:allocation, complex_cases: [complex_case_answer]) }
  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  context 'with no options' do
    let(:adapter_options) { {} }

    it 'contains a type property' do
      expect(result_data[:type]).to eql 'allocations'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql allocation.id
    end

    it 'contains a moves_count attribute' do
      expect(attributes[:moves_count]).to eql allocation.moves_count
    end

    it 'contains a date attribute' do
      expect(attributes[:date]).to eql allocation.date.iso8601
    end

    it 'contains a prisoner_category attribute' do
      expect(attributes[:prisoner_category]).to eql allocation.prisoner_category
    end

    it 'contains a sentence_length attribute' do
      expect(attributes[:sentence_length]).to eql allocation.sentence_length
    end

    it 'contains a complex_cases attribute' do
      expect(attributes[:complex_cases].first).to match complex_case_answer_attributes
    end

    it 'contains a complete_in_full attribute' do
      expect(attributes[:complete_in_full]).to eql allocation.complete_in_full
    end

    it 'contains a other_criteria attribute' do
      expect(attributes[:other_criteria]).to eql allocation.other_criteria
    end

    it 'contains a created_at attribute' do
      expect(attributes[:created_at]).to eql allocation.created_at.iso8601
    end

    it 'contains an updated_at attribute' do
      expect(attributes[:updated_at]).to eql allocation.updated_at.iso8601
    end
  end

  describe 'locations' do
    let(:adapter_options) do
      {
        include: {
          from_location: %I[location_type title],
          to_location: %I[location_type title],
        },
      }
    end
    let(:expected_json) do
      [
        {
          id: allocation.from_location_id,
          type: 'locations',
          attributes: { location_type: 'prison', title: allocation.from_location.title },
        },
        {
          id: allocation.to_location_id,
          type: 'locations',
          attributes: { location_type: 'prison', title: allocation.to_location.title },
        },
      ]
    end

    it 'contains an included from and to location' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end
end

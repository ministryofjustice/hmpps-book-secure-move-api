# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationsSerializer do
  subject(:serializer) { described_class.new(allocation, adapter_options) }

  let(:allocation) { create(:allocation) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:meta) { result_data[:meta] }

  context 'with no options' do
    let(:adapter_options) { {} }

    it 'contains a type property' do
      expect(result_data[:type]).to eql 'allocations'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql allocation.id
    end

    # Other attributes are as per AllocationSerializer, so no need to repeat everything here

    it 'contains empty meta data' do
      expect(meta).to eql({ moves: nil })
    end
  end

  context 'with custom params' do
    let(:adapter_options) do
      { params: {
        totals: {
          allocation.id => { foo: 'bar' },
        },
      } }
    end

    it 'contains meta data' do
      expect(meta).to eql({ moves: { foo: 'bar' } })
    end
  end
end

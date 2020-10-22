# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationFreeSpacesSerializer do
  subject(:serializer) { described_class.new(location, adapter_options) }

  let(:location) { create(:location) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }
  let(:meta) { result_data[:meta] }

  context 'with no options' do
    let(:adapter_options) { {} }

    it 'contains a type property' do
      expect(result_data[:type]).to eql 'locations'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql location.id
    end

    it 'contains a title attribute' do
      expect(attributes[:title]).to eql location.title
    end
  end

  context 'with custom params' do
    let(:adapter_options) do
      { params: {
        location.id => { foo: 'bar' },
      } }
    end

    it 'contains meta data' do
      expect(meta).to eql({ populations: { foo: 'bar' } })
    end
  end
end

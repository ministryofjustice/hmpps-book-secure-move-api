# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegionSerializer do
  subject(:serializer) { described_class.new(region, adapter_options) }

  let(:region) { create(:region) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }
  let(:adapter_options) { {} }

  context 'with no options' do
    it 'contains a type property' do
      expect(result_data[:type]).to eql 'regions'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql region.id
    end

    it 'contains a key attribute' do
      expect(attributes[:key]).to eql region.key
    end

    it 'contains a name attribute' do
      expect(attributes[:name]).to eql region.name
    end

    it 'contains a created_at attribute' do
      expect(attributes[:created_at]).to eql region.created_at.iso8601
    end

    it 'contains an updated_at attribute' do
      expect(attributes[:updated_at]).to eql region.updated_at.iso8601
    end
  end

  describe 'locations' do
    context 'with locations' do
      let(:location) { create(:location) }
      let(:region) { create(:region, locations: [location]) }
      let(:adapter_options) { { include: %i[locations] } }

      it 'contains a locations relationship' do
        expect(result_data[:relationships][:locations][:data]).to contain_exactly(id: location.id, type: 'locations')
      end

      it 'contain an included location' do
        expect(result[:included].map { |r| r[:type] }).to match_array('locations')
      end
    end

    context 'without locations' do
      it 'contains empty locations' do
        expect(result_data[:relationships][:locations][:data]).to be_empty
      end

      it 'does not contain an included location' do
        expect(result[:included]).to be_nil
      end
    end
  end
end

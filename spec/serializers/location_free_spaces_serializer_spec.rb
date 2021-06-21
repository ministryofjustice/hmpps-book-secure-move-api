# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
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

    it 'contains empty meta data' do
      expect(meta).to eql({ populations: nil })
    end
  end

  context 'with custom params' do
    let(:adapter_options) do
      { params: {
        spaces: {
          location.id => { foo: 'bar' },
        },
      } }
    end

    it 'contains meta data' do
      expect(meta).to eql({ populations: { foo: 'bar' } })
    end
  end

  describe 'category' do
    let(:adapter_options) { { include: described_class::SUPPORTED_RELATIONSHIPS } }

    context 'with a category' do
      let(:category) { create(:category) }
      let(:location) { create(:location, category: category) }

      it 'contains a category relationship' do
        expect(result_data[:relationships][:category]).to eq(data: { id: category.id, type: 'categories' })
      end

      it 'contains an included category' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[categories])
      end
    end

    context 'without a category' do
      it 'contains an empty category' do
        expect(result_data[:relationships][:category]).to eq(data: nil)
      end

      it 'does not contain an included category' do
        expect(result[:included]).to be_empty
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers

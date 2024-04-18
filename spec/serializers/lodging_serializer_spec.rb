# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LodgingSerializer do
  subject(:serializer) { described_class.new(lodging, adapter_options) }

  let(:lodging) { create :lodging }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:adapter_options) { {} }

  it 'contains a type property' do
    pp result[:data]
    expect(result[:data][:type]).to eql 'lodgings'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql lodging.id
  end

  it 'contains a `start_date` property' do
    expect(result[:data][:attributes][:start_date]).to eql '2023-01-01'
  end

  it 'contains an `end_date` property' do
    expect(result[:data][:attributes][:end_date]).to eql '2023-01-02'
  end

  it 'contains a `status` property' do
    expect(result[:data][:attributes][:status]).to eql 'proposed'
  end

  it 'contains a `location` relationship' do
    expect(result[:data][:relationships][:location]).to eql(data: { id: lodging.location.id, type: 'locations' })
  end

  describe 'included relationships' do
    let(:adapter_options) do
      {
        include: %w[location],
      }
    end
    let(:expected_json) do
      [
        {
          id: lodging.location_id,
          type: 'locations',
          attributes: { location_type: lodging.location.location_type, title: lodging.location.title },
        },
      ]
    end

    it 'contains an included from and to location' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end
end

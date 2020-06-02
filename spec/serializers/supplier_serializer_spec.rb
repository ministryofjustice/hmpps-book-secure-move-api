# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupplierSerializer do
  subject(:serializer) { described_class.new(supplier) }

  let(:supplier) { create(:supplier, name: 'foo', key: 'bar') }

  let(:actual_document) do
    ActiveModelSerializers::Adapter.create(serializer).serializable_hash
  end
  let(:expected_document) do
    {
      data: {
        id: supplier.id,
        type: 'suppliers',
        attributes: {
          name: 'foo',
          key: 'bar',
        },
      },
    }
  end

  it 'returns the expected document' do
    expect(actual_document).to eq(expected_document)
  end
end

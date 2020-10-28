# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategorySerializer do
  subject(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  let(:serializer) { described_class.new(category) }

  let(:category) do
    Category.new.build_from_nomis(
      category: 'Cat A',
      category_code: 'A',
    )
  end

  it 'return a serialized category' do
    expect(result[:data][:id]).to eq('A')
    expect(result[:data][:attributes]).to eq(
      title: 'Cat A',
      move_supported: false,
    )
  end
end

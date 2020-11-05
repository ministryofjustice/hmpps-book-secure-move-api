# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategorySerializer do
  subject(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  let(:serializer) { described_class.new(category) }
  let(:category) { create(:category, :not_supported) }

  it 'return a serialized category' do
    expect(result[:data][:id]).to eq(category.id)
    expect(result[:data][:attributes]).to eq(
      key: category.key,
      title: category.title,
      move_supported: false,
    )
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NationalitySerializer do
  subject(:serializer) { described_class.new(nationality) }

  let(:disabled_at) { Time.new(2019, 1, 1) }
  let(:nationality) { create :nationality, disabled_at: disabled_at }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'nationalities'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql nationality.id
  end

  it 'contains a key attribute' do
    expect(result[:data][:attributes][:key]).to eql 'british'
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql 'British'
  end

  it 'contains a disabled_at attribute' do
    expect(Time.parse(result[:data][:attributes][:disabled_at])).to eql disabled_at
  end
end

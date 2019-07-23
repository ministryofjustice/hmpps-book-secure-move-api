# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenderSerializer do
  subject(:serializer) { described_class.new(gender) }

  let(:gender) { create :gender }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'genders'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql gender.id
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eql 'female'
  end

  it 'contains a `title` attribute' do
    expect(result[:data][:attributes][:title]).to eql 'Female'
  end

  it 'contains a `disabled_at` attribute' do
    expect(result[:data][:attributes][:disabled_at]).to be_nil
  end

  it 'contains a `nomis_code` attribute' do
    expect(result[:data][:attributes][:nomis_code]).to eql 'F'
  end
end
